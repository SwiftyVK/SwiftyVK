import Foundation



public enum RequestState {
    case created
    case sended
    case successed(JSON)
    case errored(Error)
    case cancelled
}


public protocol RequestExecution {
    var state: RequestState {get}
    func cancel()
}



internal final class RequestInstance: Operation, RequestExecution {

    fileprivate static let orderedQueue: OperationQueue = {
       let q = OperationQueue()
        q.qualityOfService = QualityOfService.userInitiated
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    // almost unlimited (:
    fileprivate static let unorderedQueue: OperationQueue = {
        let q = OperationQueue()
        q.qualityOfService = QualityOfService.userInitiated
        q.maxConcurrentOperationCount = 100
        return q
    }()

    internal let id: Int64
    internal var log = [String]()
    internal fileprivate(set) var config: RequestConfig

    fileprivate let semaphore = DispatchSemaphore(value: 0)
    fileprivate var sendAttempts = 0
    fileprivate var currentSend: SendTask?
    fileprivate var result: Result!

    fileprivate let successBlock: VK.SuccessBlock?
    fileprivate let errorBlock: VK.ErrorBlock?
    fileprivate let progressBlock: VK.ProgressBlock?

    var state: RequestState = .created

    override var description: String {
        return "request #\(id)"
    }
    


    static func createWith(
        config: RequestConfig,
        successBlock: VK.SuccessBlock?,
        errorBlock: VK.ErrorBlock?,
        progressBlock: VK.ProgressBlock?
        ) -> RequestExecution {
        let instance = RequestInstance(config: config, successBlock: successBlock, errorBlock: errorBlock, progressBlock: progressBlock)
        
        VK.config.useSendLimit && config.api
            ? orderedQueue.addOperation(instance)
            : unorderedQueue.addOperation(instance)
        
        return instance
    }



    private init(
        config: RequestConfig,
        successBlock: VK.SuccessBlock?,
        errorBlock: VK.ErrorBlock?,
        progressBlock: VK.ProgressBlock?
        ) {
        self.id     = VK.Log.generateRequestId()
        self.config = config
        self.successBlock = successBlock
        self.errorBlock = errorBlock
        self.progressBlock = progressBlock
        super.init()
        result = Result(request: self)
//        VK.Log.put("Life", "init \(self)")
    }



    override func main() {
        VK.Log.put(self, "started", atNewLine: true)
        send()
        state = .sended
        semaphore.wait()
    }



    override func cancel() {
        currentSend?.cancel()
        state = .cancelled
        super.cancel()
        semaphore.signal()
        VK.Log.put(self, "cancelled")
    }



    deinit {
//        VK.Log.put("Life", "deinit \(self)")
    }
}



// MARK: - Send request & handle response
extension RequestInstance {

    func send() {
        guard !self.isCancelled else {return}

        guard sendAttempts < config.maxAttempts else {
            let error = result.error ?? result.setError(error: RequestError.maximumAttemptsExceeded)
            execute(error: error)
            return
        }

        sendAttempts += 1
        VK.Log.put(self, "send \(sendAttempts) of \(config.maxAttempts) times")
        currentSend = SendTask.createWith(id: sendAttempts, config: config, delegate: self)
    }



    func handle(sent: Int64, of expected: Int64) {
        guard !isCancelled else {return}
        VK.Log.put(self, "send \(sent) of \(expected) bytes")
        progressBlock?(sent, expected)
    }



    func handle(received: Int64, of expected: Int64) {
        guard !isCancelled else {return}
        VK.Log.put(self, "receive \(received) of \(expected) bytes")
        progressBlock?(received, expected)
    }



    func handle(data: Data) {
        guard !isCancelled else {return}
        VK.Log.put(self, "handle response with \(data.count) bytes")
        result.parseResponseFrom(data: data)
        processResult()
    }



    func handle(error: Error) {
        guard !isCancelled else {return}
        result.setError(error: error)
        processResult()
    }
}



// MARK: - Process result
extension RequestInstance {

    fileprivate func processResult() {
        if let response = result.response {
            if let nextConfig = config.nextRequest?(response) {
                VK.Log.put(self, "=== prepare next task ===")
                config = nextConfig
                sendAttempts = 0
                send()
            }
            else {
                execute(response: response)
            }
        }
        else if let error = result.error {
            catchError(error: error)
        }
    }



    fileprivate func execute(response: JSON) {
        guard !isCancelled else {return}
        VK.Log.put(self, "execute success block")
        state = .successed(response)
        successBlock?(response)
        semaphore.signal()
    }



    fileprivate func execute(error: Error) {
        guard !isCancelled else {return}
        VK.Log.put(self, "execute error block")
        state = .errored(error)
        errorBlock?(error)
        semaphore.signal()
    }



    fileprivate func catchError(error err: Error) {
        guard !isCancelled && sendAttempts < config.maxAttempts && config.catchErrors == true, let error = err as? ApiError else {
            execute(error: err)
            return
        }

        switch error.errorCode {
        case 5:
            if let error = Authorizator.authorize() {
                handle(error: error)
                break
            }
            send()
        case 14:
            guard
                let sid = error.errorUserInfo["captcha_sid"] as? String,
                let imgUrl = error.errorUserInfo["captcha_img"] as? String
                else {
                    execute(error: error)
                    return
            }

            if let error = CaptchaPresenter.present(
                sid: sid,
                imageUrl: imgUrl,
                request: self
                ) {
                handle(error: error)
                return
            }
            send()

        case 17:
            if let url = error.errorUserInfo["redirect_uri"] as? String, let error = Authorizator.validate(withUrl: url) {
                handle(error: error)
                break
            }
            send()
        default:
            execute(error: error)
        }
    }
}
