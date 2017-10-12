import Foundation

protocol AttemptSheduler: class {
    func setLimit(to: AttemptLimit)
    func shedule(attempt: Attempt, concurrent: Bool)
}

final class AttemptShedulerImpl: AttemptSheduler {
    
    private lazy var concurrentQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = .max
        return queue
    }()
    private let serialQueue: AttemptApiQueue
    
    private var limit: AttemptLimit {
        get { return serialQueue.limit }
        set { serialQueue.limit = newValue }
    }
    
    init(limit: AttemptLimit) {
        serialQueue = AttemptApiQueue(limit: limit)
    }
    
    func setLimit(to newLimit: AttemptLimit) {
        limit = newLimit
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) {
        let operation = attempt.toOperation()
        
        if concurrent {
            concurrentQueue.addOperation(operation)
        }
        else {
            serialQueue.addOperation(operation)
        }
    }
    
    deinit {
        serialQueue.killTimer()
    }
}
