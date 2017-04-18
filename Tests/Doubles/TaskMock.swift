@testable import SwiftyVK

final class TaskMock: Operation, Task {
    var state: TaskState {
        willSet {
            if case .finished = newValue {
                willChangeValue(forKey: "isFinished")
            }
        }
        didSet {
            if case .finished = state {
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    var delay = 0.01
    
    override var isFinished: Bool {
        if case .finished = state {
            return true
        }
        
        return false
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
