import Foundation

public protocol Task {
    var state: TaskState {get}
    func cancel()
}

final class TaskImpl<AttemptT: Attempt, UrlRequestFactoryT: UrlRequestFactory>: Operation, Task {
    
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
        attemptSheduler: AttemptSheduler
        ) {
        self.id = IdGenerator.next()
        self.request  = request
        self.callbacks = callbacks
        self.attemptSheduler = attemptSheduler
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
        
        guard sendAttempts < request.config.maxAttempts else {
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
        VK.Log.put(self, "send \(sendAttempts) of \(request.config.maxAttempts) times")
        
        let newAttempt = AttemptT(
            request: try UrlRequestFactoryT().make(from: request),
            timeout: request.config.timeout,
            callbacks: AttemptCallbacks(onFinish: handleResult, onSent: handleSended, onRecive: handleReceived)
        )
        
        try attemptSheduler.shedule(attempt: newAttempt, concurrent: request.rawRequest.canSentConcurrently)
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
            sendAttempts < request.config.maxAttempts,
            request.config.catchErrors == true,
            let error = rawError as? ApiError
            else {
                execute(error: rawError)
                return
        }
        
        switch error.errorCode {
        case 5:
            if let error = Authorizator.authorize() {
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
                let error = Authorizator.validate(withUrl: url) {
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
