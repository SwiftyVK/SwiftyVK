import Foundation

public protocol Task {
    var state: TaskState {get}
    func cancel()
}

final class TaskImpl<AttemptT: Attempt>: Operation, Task {
    
    let id: Int64
    var state: TaskState = .created {
        willSet {
            if case .finished = newValue {
                willChangeValue(forKey: "isFinished")
            }
        }
        didSet {
            if case .finished = state {
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    var log = [String]()
    
    private var request: Request
    private let callbacks: Callbacks
    private let semaphore = DispatchSemaphore(value: 0)
    private var sendAttempts = 0
    private var attemptSheduler: AttemptSheduler
    private var urlRequestBuilder: UrlRequestBuilder
    private weak var currentAttempt: Attempt?
    
    override var isFinished: Bool {
        if case .finished = state {
            return true
        }
        
        return false
    }
    
    override var description: String {
        return "task #\(id)"
    }
    
    init(
        request: Request,
        callbacks: Callbacks,
        attemptSheduler: AttemptSheduler,
        urlRequestBuilder: UrlRequestBuilder
        ) {
        self.id = IdGenerator.next()
        self.request  = request
        self.callbacks = callbacks
        self.attemptSheduler = attemptSheduler
        self.urlRequestBuilder = urlRequestBuilder
        super.init()
    }
    
    override func main() {
        VK.Log.put(self, "started", atNewLine: true)
        trySend()
        state = .sended
        semaphore.wait()
    }
    
    override func cancel() {
        currentAttempt?.cancel()
        state = .cancelled
        super.cancel()
        semaphore.signal()
        VK.Log.put(self, "cancelled")
    }
    
    private func resendWith(error: Error?) {
        guard !self.isCancelled else {return}
        
        guard sendAttempts < request.config.maxAttemptsLimit.count else {
            if let error = error {
                execute(error: error)
            }
            else {
                execute(error: RequestError.maximumAttemptsExceeded)
            }
            
            return
        }
        
        trySend()
    }
    
    private func trySend() {
        do {
            try send()
        }
        catch let error {
            execute(error: error)
        }
    }
    
    private func send() throws {
        guard !self.isCancelled else {return}
        
        sendAttempts += 1
        VK.Log.put(self, "send \(sendAttempts) of \(request.config.maxAttemptsLimit.count) times")
        
        let urlRequest = try urlRequestBuilder.make(
            from: request.rawRequest,
            httpMethod: request.config.httpMethod,
            config: request.config,
            capthca: makeCaptcha()
        )
        
        let newAttempt = AttemptT(
            request: urlRequest,
            timeout: request.config.attemptTimeout,
            callbacks: AttemptCallbacks(onFinish: handleResult, onSent: handleSended, onRecive: handleReceived)
        )
        
        try attemptSheduler.shedule(attempt: newAttempt, concurrent: request.rawRequest.canSentConcurrently)
        currentAttempt = newAttempt
        
    }
    
    private func makeCaptcha() -> Captcha? {
        var captcha: Captcha?
        
        if let sid = sharedCaptchaAnswer?["captcha_sid"], let key = sharedCaptchaAnswer?["captcha_key"] {
            captcha = (sid: sid, key: key)
            sharedCaptchaAnswer = nil
        }
        
        return captcha
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
    
    private func handleResult(_ result: Result) {
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
            let error = rawError as? ApiError
            else {
                execute(error: rawError)
                return
        }
        
        switch error.errorCode {
        case 5:
            if let error = LegacyAuthorizator.authorize() {
                handleResult(.error(error))
                break
            }
            resendWith(error: error)
        case 14:
            guard
                let sid = error.errorUserInfo["captcha_sid"] as? String,
                let imgUrl = error.errorUserInfo["captcha_img"] as? String
                else {
                    execute(error: error)
                    return
            }
            
            if let error = CaptchaPresenter.present(sid: sid, imageUrl: imgUrl, request: self) {
                handleResult(.error(error))
                return
            }
            resendWith(error: error)
        case 17:
            if
                let url = error.errorUserInfo["redirect_uri"] as? String,
                let error = LegacyAuthorizator.validate(withUrl: url) {
                handleResult(.error(error))
                break
            }
            resendWith(error: error)
        default:
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
