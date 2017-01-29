import Foundation


private let sessionConfig = URLSessionConfiguration.default
private let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
private let sendTaskQueue = DispatchQueue(label: "SwiftyVK.SendTaskQueue")


internal final class SendTask: Operation {
    unowned private let delegate: RequestInstance
    private let config: RequestConfig
    private var task: URLSessionTask!
    private let id: Int
    private let reqId: Int64



    override var description: String {
        return "task #\(delegate.id)-\(id)"
    }



    static func createWith(id: Int, config: RequestConfig, delegate: RequestInstance) -> SendTask {
        let operation = SendTask(id: id, config: config, delegate: delegate)
        SendQueue.queue.add(task: operation, api: config.api)
        return operation
    }



    private init(id: Int, config: RequestConfig, delegate: RequestInstance) {
        self.id         = id
        self.reqId      = delegate.id
        self.config     = config
        self.delegate   = delegate
        super.init()
//        VK.Log.put("Life", "init \(self)")
    }



    override func main() {
        let semaphore = DispatchSemaphore(value: 0)

        let completeon: (Data?, URLResponse?, Error?) -> () = {data, response, error in
            
            defer {
                semaphore.signal()
            }
            
            guard !self.isCancelled else {return}

            if let error = error {
                self.delegate.handle(error: error)
            }
            else if let data = data {
                self.delegate.handle(data: data)
            }
            else {
                self.delegate.handle(error: RequestError.unexpectedResponse)
            }
        }
        
        sendTaskQueue.sync {
            sessionConfig.timeoutIntervalForRequest = config.timeout
            sessionConfig.timeoutIntervalForResource = config.timeout
            
            let urlRequest = UrlFabric.createWith(config: config)
            self.task = session.dataTask(with: urlRequest, completionHandler: completeon)
            
            task.addObserver(self, forKeyPath: #keyPath(URLSessionTask.countOfBytesReceived), options: .new, context: nil)
            task.addObserver(self, forKeyPath: #keyPath(URLSessionTask.countOfBytesSent), options: .new, context: nil)
            
            task.resume()
        }
        
        semaphore.wait()
    }



    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {return}

        switch keyPath {
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
        VK.Log.put(delegate, "cancel \(self)")
    }



    deinit {
//        VK.Log.put("Life", "deinit \(self)")
        task.removeObserver(self, forKeyPath: #keyPath(URLSessionTask.countOfBytesReceived))
        task.removeObserver(self, forKeyPath: #keyPath(URLSessionTask.countOfBytesSent))
    }
}
