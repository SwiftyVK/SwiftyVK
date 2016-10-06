import Foundation



public protocol RequestPointer : CustomStringConvertible {
    func cancel()
}



internal final class RequestInstance : Operation, RequestPointer, SendDelegate {

    static let queue = OperationQueue()
    
    
    internal let request: URLRequest
    internal let isApi: Bool
    fileprivate let semaphore = DispatchSemaphore(value: 0)
    fileprivate let successBlock: VK.SuccessBlock
    fileprivate let errorBlock: VK.ErrorBlock
    fileprivate let progressBlock: VK.ProgressBlock
    fileprivate let catchErrors: Bool
    fileprivate var sendAttempts = 0
    fileprivate var maxAttempts = 0
    fileprivate var currentSend: SendOperation?
    fileprivate var result = Result()
    
    
    internal let id: Int64
    internal var log = [String]()
    internal let logToConsole: Bool
    
    override var description : String {
        get {return "Request \(id)\n   Url:    \(request.url?.absoluteString ?? "nil")\n   Body:   \(request.httpBody?.count ?? 0) bytes\n   Sended: \(sendAttempts) of \(maxAttempts) times)\n   Result: \(result)"
        }
    }
    
    
    
    static func createWith(request: Request) -> RequestPointer {
        let instance = RequestInstance(request: request)
        queue.addOperation(instance)
        return instance
    }
    
    
    
    private init(request: Request) {
        self.id = VK.Log.generateRequestId()
        self.request = request.urlRequest
        self.isApi = request.isAPI
        self.catchErrors = request.catchErrors
        self.maxAttempts = request.maxAttempts
        self.successBlock = request.successBlock
        self.progressBlock = request.progressBlock
        self.errorBlock = request.errorBlock
        self.logToConsole = request.logToConsole
        super.init()
        VK.Log.put(self, "init \(self)")
    }
    
    
    
    override func main() {
        VK.Log.put(self, "started")
        send()
    }
    
    
    
    override func cancel() {
        currentSend?.cancel()
        super.cancel()
        semaphore.signal()
        VK.Log.put(self, "cancelled")
    }
    
    
    
    deinit {
        VK.Log.put(self, "deinit \(self)", sync: true)
    }
}



//MARK: - Send request & handle response
extension RequestInstance {


    
    func send() {
        guard !self.isCancelled else {return}
        
        VK.Log.put(self, "send \(sendAttempts+1) of \(maxAttempts) times")
        currentSend = SendOperation.createWith(delegate: self)
        sendAttempts += 1
        semaphore.wait()
    }
    
    
    
    func handle(sended: Int64, of expected: Int64) {
        VK.Log.put(self, "send \(sended) of \(expected) bytes")
    }
    
    
    
    func handle(received: Int64, of expected: Int64) {
        VK.Log.put(self, "receive \(received) of \(expected) bytes")
        progressBlock(received, expected)
    }
    
    
    
    func handle(data: Data) {
        VK.Log.put(self, "handle data with \(data.count) bytes")
        result.parseResponseFrom(data: data)
        processResult()
    }
    
    
    
    func handle(error: Error) {
        VK.Log.put(self, "handle error \(error)")
        result.setError(error: error)
        processResult()
    }
}



//MARK: - Process result
extension RequestInstance {
    
    
    
    fileprivate func processResult() {
        if let response = result.response {
            execute(response: response)
        }
        else if let error = result.error {
            catchError(error: error)
        }
    }
    
    
    
    fileprivate func execute(response: JSON) {
        VK.Log.put(self, "execute success block")
        successBlock(response)
        semaphore.signal()
    }
    
    
    
    fileprivate func catchError(error: Error) {
        guard sendAttempts < maxAttempts && catchErrors == true, let apiError = error as? VKAPIError else {
            execute(error: error)
            return
        }
        
        switch apiError._code {
        case 5:
            sendAttempts -= 1
            Authorizator.authorize(self)
        case 14:
            if !sharedCaptchaIsRun {
                СaptchaController.start(
                    sid: apiError.info["captcha_sid"] as! String,
                    imageUrl: apiError.info["captcha_img"] as! String,
                    request: self)
            }
        case 17:
            WebController.validate(self, validationUrl: apiError.info["redirect_uri"] as! String)
        default:
            execute(error: error)
        }
    }
    
    
    
    fileprivate func execute(error: Error) {
        VK.Log.put(self, "execute error block")
        errorBlock(error)
        semaphore.signal()
    }
}
