protocol TaskSheduler: class {
    func shedule(task: Task, concurrent: Bool) throws
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
    
    func shedule(task: Task, concurrent: Bool) throws {
        guard let task = task as? Operation else {
            throw RequestError.wrongTaskType
        }
        
        if concurrent {
            concurrentQueue.addOperation(task)
        }
        else {
            serialQueue.addOperation(task)
        }
    }
}
