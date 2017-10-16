import Foundation

public protocol Task: OperationConvertible {
    var state: TaskState { get }
}

final class TaskImpl: Operation, Task {
    
    let id: Int64
    
    override var isFinished: Bool {
        switch state {
        case .finished, .failed, .cancelled:
            return true
        case .created, .sended:
            return false
        }
    }
    
    var state: TaskState = .created {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    
    override var description: String {
        return "task #\(id), state: \(state)"
    }
    
    private var currentRequest: Request
    private let session: TaskSession
    private let semaphore = DispatchSemaphore(value: 0)
    private var sendAttempts = 0
    private let urlRequestBuilder: UrlRequestBuilder
    private let attemptMaker: AttemptMaker
    private let apiErrorHandler: ApiErrorHandler
    private weak var currentAttempt: Attempt?
    
    init(
        id: Int64,
        request: Request,
        session: TaskSession,
        urlRequestBuilder: UrlRequestBuilder,
        attemptMaker: AttemptMaker,
        apiErrorHandler: ApiErrorHandler
        ) {
        self.id = id
        self.currentRequest = request
        self.session = session
        self.urlRequestBuilder = urlRequestBuilder
        self.attemptMaker = attemptMaker
        self.apiErrorHandler = apiErrorHandler
        super.init()
    }
    
    override func main() {
        state = .sended
        tryToSend()
        semaphore.wait()
        session.dismissCaptcha()
    }
    
    override func cancel() {
        super.cancel()
        currentAttempt?.cancel()
        state = .cancelled
        semaphore.signal()
    }
    
    private func resendWith(error: VKError?, captcha: Captcha?) {
        guard !self.isCancelled else { return }
        
        guard sendAttempts < currentRequest.config.attemptsMaxLimit.count else {
            if let error = error {
                return perform(error: error)
            }
            else {
                return perform(error: .maximumAttemptsExceeded)
            }
        }
        
        tryToSend(captcha: captcha)
    }
    
    private func tryToSend(captcha: Captcha? = nil) {
        guard !self.isCancelled else { return }

        tryToPerform {
            try send(captcha: captcha)
        }
    }
    
    private func send(captcha: Captcha?) throws {
        guard !self.isCancelled else { return }
        
        sendAttempts += 1
        
        let urlRequest = try urlRequestBuilder.build(
            type: currentRequest.type,
            config: currentRequest.config,
            capthca: captcha,
            token: session.token
        )
        
        let newAttempt = attemptMaker.attempt(
            request: urlRequest,
            callbacks: AttemptCallbacks(onFinish: handleResult, onSent: handleSended, onRecive: handleReceived)
        )

        currentAttempt = newAttempt
        try session.shedule(attempt: newAttempt, concurrent: currentRequest.canSentConcurrently)
    }
    
    private func handleSended(_ current: Int64, of expected: Int64) {
        guard !isCancelled && currentRequest.config.handleProgress else { return }
        currentRequest.callbacks.onProgress?(.sended, current, expected)
    }
    
    private func handleReceived(_ current: Int64, of expected: Int64) {
        guard !isCancelled && currentRequest.config.handleProgress else { return }
        currentRequest.callbacks.onProgress?(.recieved, current, expected)
    }
    
    private func handleResult(_ result: Response) {
        guard !isCancelled else { return }
        
        switch result {
        case .success(let response):
            var next: Request?
            
            tryToPerform {
                next = try currentRequest.next(with: response)
            }
            
            if let next = next {
                currentRequest = next
                sendAttempts = 0
                tryToSend()
            }
            else {
                tryToPerform {
                    try perform(response: response)
                }
            }
        case .error(let error):
            catchApiError(error: error)
        }
    }
    
    private func catchApiError(error vkError: VKError) {
        guard !isCancelled else { return }
        
        guard currentRequest.config.handleErrors == true else {
            return perform(error: vkError)
            
        }
        
        guard  let apiError = vkError.toApi() else {
            return perform(error: vkError)
        }
        
        tryToPerform {
            let result = try apiErrorHandler.handle(error: apiError)
            
            switch result {
            case .none:
                resendWith(error: apiError.toVK, captcha: nil)
            case .captcha(let captcha):
                sendAttempts -= 1
                resendWith(error: apiError.toVK, captcha: captcha)
            }
        }
    }
    
    private func tryToPerform(code: () throws -> ()) {
        guard !isCancelled else { return }

        do {
            try code()
        }
        catch let error as VKError {
            perform(error: error)
        }
        catch let error {
            perform(error: .unknown(error))
        }
    }
    
    private func perform(error: VKError) {
        guard !isCancelled && !isFinished else { return }
        state = .failed(error)
        currentRequest.callbacks.onError?(error)
        semaphore.signal()
    }
    
    private func perform(response: Data) throws {
        guard !isCancelled && !isFinished else { return }
        try currentRequest.callbacks.onSuccess?(response)
        state = .finished(response)
        semaphore.signal()
    }
}

public enum TaskState {
    case created
    case sended
    case finished(Data)
    case failed(VKError)
    case cancelled
}
