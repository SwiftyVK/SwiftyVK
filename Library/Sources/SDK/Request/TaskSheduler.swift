protocol TaskSheduler {
    func shedule(task: Task, concurrent: Bool)
}

final class TaskShedulerImpl: TaskSheduler {
    
    private let serialQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue(
            label: "SwiftyVK.serialTaskQueue",
            qos: .userInitiated
        )
        return queue
    }()
    
    private let concurrentQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue(
            label: "SwiftyVK.concurrentTaskQueue",
            qos: .userInitiated,
            attributes: .concurrent
        )
        return queue
    }()
    
    func shedule(task: Task, concurrent: Bool) {
        guard let task = task as? Operation else {
            return
        }
        
        if concurrent {
            concurrentQueue.addOperation(task)
        }
        else {
            serialQueue.addOperation(task)
        }
    }
}
