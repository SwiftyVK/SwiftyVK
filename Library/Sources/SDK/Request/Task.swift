import Foundation

public protocol Task {
    var state: TaskState {get}
    func cancel()
}

final class TaskImpl: Operation, Task {
    
    let id: Int64
    var state: TaskState = .created {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    var log = [String]()
    
    private var request: Request
    private let callbacks: Callbacks
    private let session: TaskSession
    private let semaphore = DispatchSemaphore(value: 0)
    private var sendAttempts = 0
    private let urlRequestBuilder: UrlRequestBuilder
    private let attemptMaker: AttemptMaker
    private let apiErrorHandler: ApiErrorHandler
    private weak var currentAttempt: Attempt?
    
    override var isFinished: Bool {
        switch state {
        case .finished, .failed, .cancelled:
            return true
        case .created, .sended:
            return false
        }
    }
    
    override var description: String {
        return "task #\(id), state: \(state)\n"
    }
    
    init(
        request: Request,
        callbacks: Callbacks,
        session: TaskSession,
        urlRequestBuilder: UrlRequestBuilder,
        attemptMaker: AttemptMaker,
        apiErrorHandler: ApiErrorHandler
        ) {
        self.id = IdGenerator.next()
        self.request  = request
        self.callbacks = callbacks
        self.session = session
        self.urlRequestBuilder = urlRequestBuilder
        self.attemptMaker = attemptMaker
        self.apiErrorHandler = apiErrorHandler
        super.init()
    }
    
    override func main() {
        VK.Log.put(self, "started", atNewLine: true)
        trySend()
        state = .sended
        semaphore.wait()
        session.dismissCaptcha()
    }
    
    override func cancel() {
        currentAttempt?.cancel()
        super.cancel()
        state = .cancelled
        semaphore.signal()
        VK.Log.put(self, "cancelled")
    }
    
    private func resendWith(error: Error?, captcha: Captcha?) {
        guard !self.isCancelled else {return}
        
        guard sendAttempts < request.config.maxAttemptsLimit.count else {
            if let error = error {
                execute(error: error)
            }
            else {
                execute(error: LegacyRequestError.maximumAttemptsExceeded)
            }
            
            return
        }
        
        trySend(captcha: captcha)
    }
    
    private func trySend(captcha: Captcha? = nil) {
        do {
            try send(captcha: captcha)
        } catch let error {
            execute(error: error)
        }
    }
    
    private func send(captcha: Captcha?) throws {
        guard !self.isCancelled else {return}
        
        sendAttempts += 1
        VK.Log.put(self, "send \(sendAttempts) of \(request.config.maxAttemptsLimit.count) times")
        
        let urlRequest = try urlRequestBuilder.build(
            request: request.rawRequest,
            httpMethod: request.config.httpMethod,
            config: request.config,
            capthca: captcha,
            token: session.token
        )
        
        let newAttempt = attemptMaker.attempt(
            request: urlRequest,
            timeout: request.config.attemptTimeout,
            callbacks: AttemptCallbacks(onFinish: handleResult, onSent: handleSended, onRecive: handleReceived)
        )
        
        try session.shedule(attempt: newAttempt, concurrent: request.rawRequest.canSentConcurrently)
        currentAttempt = newAttempt
    }
    
    private func handleSended(_ total: Int64, of expected: Int64) {
        guard !isCancelled else {return}
        VK.Log.put(self, "send \(total) of \(expected) bytes")
    }
    
    private func handleReceived(_ total: Int64, of expected: Int64) {
        guard !isCancelled else {return}
        VK.Log.put(self, "receive \(total) of \(expected) bytes")
        callbacks.onProgress?(total, expected)
    }
    
    private func handleResult(_ result: LegacyResult) {
        guard !isCancelled else { return }
        
        switch result {
        case .data(let response):
            if let next = request.nexts.popLast()?(response) {
                VK.Log.put(self, "=== prepare next task ===")
                request = next
                sendAttempts = 0
                trySend()
            }
            else {
                execute(response: response)
            }
        case .error(let error):
            `catch`(error: error)
        }
    }
    
    private func execute(response: JSON) {
        guard !isCancelled else { return }
        VK.Log.put(self, "execute success block")
        state = .finished(response)
        callbacks.onSuccess?(response)
        semaphore.signal()
    }
    
    private func execute(error: Error) {
        guard !isCancelled else { return }
        VK.Log.put(self, "execute error block")
        state = .failed(error)
        callbacks.onError?(error)
        semaphore.signal()
    }
    
    private func `catch`(error rawError: Error) {
        guard
            !isCancelled,
            sendAttempts < request.config.maxAttemptsLimit.count,
            request.config.handleErrors == true,
            let error = rawError as? LegacyApiError
            else {
                execute(error: rawError)
                return
        }
        
        do {
            let result = try apiErrorHandler.handle(error: error)
            
            switch result {
            case .none:
                resendWith(error: error, captcha: nil)
            case .captcha(let captcha):
                sendAttempts -= 1
                resendWith(error: error, captcha: captcha)
            }
        }
        catch let error {
            execute(error: error)
        }
    }
}

public enum TaskState {
    case created
    case sended
    case finished(JSON)
    case failed(Error)
    case cancelled
}

struct IdGenerator {
    static let queue = DispatchQueue(label: "")
    static var id: Int64 = 0
    
    static func next() -> Int64 {
        return queue.sync {
            id += 1
            return id
        }
    }
}
