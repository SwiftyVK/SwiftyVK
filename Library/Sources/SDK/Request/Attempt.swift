import Foundation

private let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
private let attemptQueue = DispatchQueue(label: "SwiftyVK.AttemptQueue")

protocol Attempt: class {
    init(request: URLRequest, timeout: TimeInterval, callbacks: AttemptCallbacks)
    func cancel()
}

final class AttemptImpl: Operation, Attempt {
    
    private let request: URLRequest
    private let timeout: TimeInterval
    private var task: URLSessionTask!
    private let callbacks: AttemptCallbacks
    private var taskIsFinished = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    
    override var isFinished: Bool {
        return taskIsFinished
    }
    
    init(request: URLRequest, timeout: TimeInterval, callbacks: AttemptCallbacks) {
        self.request = request
        self.timeout = timeout
        self.callbacks = callbacks
        super.init()
    }

    override func main() {

        let completion: (Data?, URLResponse?, Error?) -> () = { [weak self] data, response, error in
            guard let `self` = self, !self.isCancelled else { return }

            if let error = error {
                self.callbacks.onFinish(.error(.urlRequestError(error)))
            }
            else if let data = data {
                self.callbacks.onFinish(Response(data))
            }
            else {
                self.callbacks.onFinish(.error(.unexpectedResponse))
            }
            
            self.taskIsFinished = true
        }
        
        attemptQueue.sync {
            session.configuration.timeoutIntervalForRequest = self.timeout
            session.configuration.timeoutIntervalForResource = self.timeout

            self.task = session.dataTask(with: request, completionHandler: completion)
            
            task.addObserver(self, forKeyPath: #keyPath(URLSessionTask.countOfBytesReceived), options: .new, context: nil)
            task.addObserver(self, forKeyPath: #keyPath(URLSessionTask.countOfBytesSent), options: .new, context: nil)
            
            task.resume()
        }
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        ) {
        guard let keyPath = keyPath else {return}
        
        switch keyPath {
        case (#keyPath(URLSessionTask.countOfBytesSent)):
            callbacks.onSent(task.countOfBytesSent, task.countOfBytesExpectedToSend)
        case(#keyPath(URLSessionTask.countOfBytesReceived)):
            callbacks.onRecive(task.countOfBytesExpectedToReceive, task.countOfBytesExpectedToReceive)
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
    }
}

struct AttemptCallbacks {
    let onFinish: (Response) -> ()
    let onSent: (_ total: Int64, _ of: Int64) -> ()
    let onRecive: (_ total: Int64, _ of: Int64) -> ()
}
