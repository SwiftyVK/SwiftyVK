import SwiftyVK

final class TaskMock: Operation, Task {
    var state: TaskState
    var delay = 0.1
    
    override var isFinished: Bool {
        return state == .finished(JSON(true))
    }
    
    override init() {
        state = .created
    }
    
    override func main() {
        super.main()
        state = .created
        
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            self.finish()
        }
    }
    
    private func finish() {
        state = .finished(JSON(true))
    }
    
    override func cancel() {
        super.cancel()
        state = .cancelled
    }
}

final class WrongTaskMock: Task {
    var state = TaskState.created
    func cancel() {}
}
