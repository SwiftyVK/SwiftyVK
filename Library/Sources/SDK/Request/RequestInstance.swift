import Foundation



public protocol RequestExecution {
    func cancel()
}



internal final class RequestInstance : Operation, RequestExecution {
    fileprivate static let queue: OperationQueue = {
       let q = OperationQueue()
        q.qualityOfService = QualityOfService.userInitiated
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    internal let id: Int64
    internal var log = [String]()
    internal fileprivate(set) var config: RequestConfig
    
    fileprivate let semaphore = DispatchSemaphore(value: 0)
    fileprivate var sendAttempts = 0
    fileprivate var currentSend: SendTask?
    fileprivate var result: Result!
    
    fileprivate let successBlock:  VK.SuccessBlock?
    fileprivate let errorBlock: VK.ErrorBlock?
    fileprivate let progressBlock: VK.ProgressBlock?
    
    override var description : String {
        return "request #\(id)"
    }
    
    
    
    static func createWith(
        config: RequestConfig,
        successBlock: VK.SuccessBlock?,
        errorBlock: VK.ErrorBlock?,
        progressBlock: VK.ProgressBlock?
        ) -> RequestExecution {
        let instance = RequestInstance(config: config, successBlock: successBlock, errorBlock: errorBlock, progressBlock: progressBlock)
        queue.addOperation(instance)
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
        semaphore.wait()
    }
    
    
    
    override func cancel() {
        currentSend?.cancel()
        super.cancel()
        semaphore.signal()
        VK.Log.put(self, "cancelled")
    }
    
    
    
    deinit {
//        VK.Log.put("Life", "deinit \(self)")
    }
}



//MARK: - Send request & handle response
extension RequestInstance {


    
    func send() {
        guard !self.isCancelled else {return}
        
        guard sendAttempts < config.maxAttempts else {
            if result.error == nil {
                result.setError(error: ErrorRequest.maximumAttemptsExceeded)
            }
            
            execute(error: result.error!)
            return
        }
        
        
        sendAttempts += 1
        VK.Log.put(self, "send \(sendAttempts) of \(config.maxAttempts) times")
        currentSend = SendTask.createWith(id: sendAttempts, config: config, delegate: self)
    }
    
    
    
    func handle(sended: Int64, of expected: Int64) {
        VK.Log.put(self, "send \(sended) of \(expected) bytes")
    }
    
    
    
    func handle(received: Int64, of expected: Int64) {
        VK.Log.put(self, "receive \(received) of \(expected) bytes")
        progressBlock?(received, expected)
    }
    
    
    
    func handle(data: Data) {
        VK.Log.put(self, "handle response with \(data.count) bytes")
        result.parseResponseFrom(data: data)
        processResult()
    }
    
    
    
    func handle(error: Error) {
        result.setError(error: error)
        processResult()
    }
}



//MARK: - Process result
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
        VK.Log.put(self, "execute success block")
        successBlock?(response)
        semaphore.signal()
    }
    
    
    
    fileprivate func execute(error: Error) {
        VK.Log.put(self, "execute error block")
        errorBlock?(error)
        semaphore.signal()
    }
    
    
    
    fileprivate func catchError(error err: Error) {
        guard sendAttempts < config.maxAttempts && config.catchErrors == true, let error = err as? ErrorAPI else {
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
            guard !sharedCaptchaIsRun else {return}
            
            СaptchaController.start(
                sid: error.errorUserInfo["captcha_sid"] as! String,
                imageUrl: error.errorUserInfo["captcha_img"] as! String,
                request: self)
        case 17:
            if let error = WebPresenter.start(withUrl: error.errorUserInfo["redirect_uri"] as! String) {
                handle(error: error)
                break
            }
            send()
        default:
            execute(error: error)
        }
    }
}
