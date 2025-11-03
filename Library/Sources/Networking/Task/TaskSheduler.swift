import Foundation

protocol TaskSheduler: AnyObject {
    func shedule(task: Task)
}

final class TaskShedulerImpl: TaskSheduler {
    
    private lazy var taskQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = .max
        return queue
    }()
    
    func shedule(task: Task) {
        let operation = (task as? OperationConvertible)?.toOperation()
        operation.flatMap { taskQueue.addOperation($0) }
    }
}
