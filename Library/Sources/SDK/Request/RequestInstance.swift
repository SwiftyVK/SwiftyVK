import Foundation



protocol RequestPointer {
    func cancel()
}



internal final class RequestInstance : Operation, RequestPointer, SendDelegate {

    static let queue = OperationQueue()
    
    
    
    internal let request: URLRequest
    internal let isApi: Bool
    fileprivate let semaphore = DispatchSemaphore(value: 0)
    fileprivate let successBlock: VK.SuccessBlock
    fileprivate let errorBlock: VK.ErrorBlock
    fileprivate var sendAttempts = 0
    fileprivate var currentSend: SendOperation?
    
    
    
    static func createWith(request: Request) -> RequestPointer {
        let instance = RequestInstance(request: request)
        queue.addOperation(instance)
        return instance
    }
    
    
    
    private init(request: Request) {
        self.request = request.urlRequest
        self.isApi = request.isAPI
        self.successBlock = request.successBlock
        self.errorBlock = request.errorBlock
        super.init()
    }
    
    
    
    override func main() {
        send()
    }
    
    
    
    override func cancel() {
        currentSend?.cancel()
        super.cancel()
        semaphore.signal()
    }
}










//MARK: - Methods
extension RequestInstance {


    func send() {
        guard !self.isCancelled else {return}
        currentSend = SendOperation.createWith(delegate: self)
        semaphore.wait()
    }
    
    
    
    func handle(data: Data) {
//        print("DATA")
        print(JSON(data: data)["error"])
        semaphore.signal()
    }
    func handle(error: Error) {
        print("ERROR")
        semaphore.signal()
    }
    func handle(code: Int) {
//        print("CODE")
    }
    func handle(received: Int64, of: Int64) {
//        print("RECEIVED")
    }
    func handle(sended: Int64, of: Int64) {
//        print("SENDED")
    }
}
