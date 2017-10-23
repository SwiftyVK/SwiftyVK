protocol TaskSheduler: class {
    func shedule(task: Task, concurrent: Bool)
}

final class TaskShedulerImpl: TaskSheduler {
    
    private lazy var serialQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private lazy var concurrentQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = .max
        return queue
    }()
    
    func shedule(task: Task, concurrent: Bool) {
        let operation = (task as? OperationConvertible)?.toOperation()
        
        if concurrent {
            operation.flatMap { concurrentQueue.addOperation($0) }
        }
        else {
            operation.flatMap { serialQueue.addOperation($0) }
        }
    }
}
