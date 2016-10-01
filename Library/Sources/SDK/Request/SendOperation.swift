import Foundation



private let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)



protocol SendDelegate: class {
    var request: URLRequest {get}
    var isApi: Bool {get}
    func handle(data: Data)
    func handle(error: Error)
    func handle(code: Int)
    func handle(sended: Int64, of: Int64)
    func handle(received: Int64, of: Int64)
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
        
        self.task = session.dataTask(with: self.delegate.request) {data, response, error in
            if let data = data {
                self.delegate.handle(data: data)
            }
            else if let error = error {
                self.delegate.handle(error: error)
            }
            else if let responseCode = (response as? HTTPURLResponse)?.statusCode {
                self.delegate.handle(code: responseCode)
            }
            
            semaphore.signal()
        }
        
        
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
