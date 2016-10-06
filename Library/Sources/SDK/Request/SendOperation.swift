import Foundation



private let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)



protocol SendDelegate: class {
    var request: URLRequest {get}
    var isApi: Bool {get}
    func handle(sended: Int64, of: Int64)
    func handle(received: Int64, of: Int64)
    func handle(data: Data)
    func handle(error: Error)
}



final class SendOperation : Operation {
    unowned private let delegate: SendDelegate
    private var task: URLSessionTask!
    
    
    
    static func createWith(delegate: SendDelegate) -> SendOperation {
        let operation = SendOperation(delegate: delegate)
        
        
        if delegate.isApi {
            SendQueue.queue.addApi(operation)
        }
        else {
            SendQueue.queue.addNotApi(operation)
        }
        return operation
    }
    
    
    
    private init(delegate: SendDelegate) {
        self.delegate = delegate
    }
    
    
    
    
    override func main() {
        let semaphore = DispatchSemaphore(value: 0)
        
        let completeon : (Data?, URLResponse?, Error?) -> () = {data, response, error in
            guard !self.isCancelled else {
                semaphore.signal()
                return
            }
            
            if let data = data {
                self.delegate.handle(data: data)
            }
            else if let error = error {
                self.delegate.handle(error: error)
            }
            else {
                self.delegate.handle(error: VKRequestError.unexpectedResponse)
            }
            
            semaphore.signal()
        }
        
        self.task = session.dataTask(with: delegate.request, completionHandler: completeon)
        
        task.addObserver(self, forKeyPath: #keyPath(URLSessionTask.countOfBytesReceived), options: NSKeyValueObservingOptions.new, context: nil)
        task.addObserver(self, forKeyPath: #keyPath(URLSessionTask.countOfBytesSent), options: NSKeyValueObservingOptions.new, context: nil)
        
        task.resume()
        semaphore.wait()
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {return}
        
        switch(keyPath) {
        case (#keyPath(URLSessionTask.countOfBytesReceived)):
            delegate.handle(received: task.countOfBytesExpectedToReceive, of: task.countOfBytesExpectedToReceive)
        case(#keyPath(URLSessionTask.countOfBytesSent)):
            delegate.handle(received: task.countOfBytesSent, of: task.countOfBytesExpectedToSend)
        default:
            break
        }
    }
    
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    
    
    deinit {
        task.removeObserver(self, forKeyPath: #keyPath(URLSessionTask.countOfBytesReceived))
        task.removeObserver(self, forKeyPath: #keyPath(URLSessionTask.countOfBytesSent))
//        print("DEINIT SEND_OPERATION")
    }
}
