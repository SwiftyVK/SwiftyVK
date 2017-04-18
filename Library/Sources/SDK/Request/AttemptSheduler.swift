import Foundation

protocol AttemptSheduler {
    func shedule(attempt: Attempt, concurrent: Bool) throws
}

final class AttemptShedulerImpl: AttemptSheduler {
    
    private lazy var concurrentQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = .max
        return queue
    }()
    private let serialQueue: AttemptApiQueue
    
    var limit: Int {
        get { return serialQueue.limit }
        set { serialQueue.limit = newValue }
    }
    
    init(limit: Int) {
        serialQueue = AttemptApiQueue(limit: limit)
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {
        guard let attempt = attempt as? Operation else {
            throw RequestError.wrongAttemptType
        }
        
        if concurrent {
            concurrentQueue.addOperation(attempt)
        }
        else {
            serialQueue.addOperation(attempt)
        }
    }
}

private class AttemptApiQueue: OperationQueue {
    
    private let counterQueue = DispatchQueue(label: "SwiftyVK.couterQueue")
    private let attemptsQueue = DispatchQueue(
        label: "SwiftyVK.serialAttemptQueue",
        qos: .userInitiated
    )
    
    private var sent = 0
    private var waited = [Operation]()
    var limit: Int
    
    init(limit: Int) {
        self.limit = limit
        
        super.init()
        underlyingQueue = attemptsQueue
        
        counterQueue.async {
            let timer = Timer(
                timeInterval: 1,
                target: self,
                selector: #selector(self.dropCounter),
                userInfo: nil,
                repeats: true
            )
            timer.tolerance = 0.01
            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
            CFRunLoopRun()
        }
    }
    
    override func addOperation(_ operation: Operation) {
        attemptsQueue.async {
            self.addOperationSync(operation)
        }
    }
    
    private func addOperationSync(_ operation: Operation) {
        if limit < 1 || sent < limit {
            sent += 1
            super.addOperation(operation)
        }
        else {
            waited.append(operation)
        }
    }

    @objc
    private func dropCounter() {
        attemptsQueue.async(execute: dropCounterSync)
    }
    
    private func dropCounterSync() {
        guard !waited.isEmpty || sent > 0 else { return }
        
        self.sent = 0
        
        while !waited.isEmpty && sent < limit {
            sent += 1
            let op = waited.removeFirst()
            super.addOperation(op)
        }
    }
}
