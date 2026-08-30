@testable import SwiftyVK

final class TaskMock: Operation, Task, OperationConvertible {

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
    var runTime = 0.01
    private(set) var cancelCallCount = 0
    var onCancel: (() -> ())?
    
    override var isFinished: Bool {
        if case .finished = state {
            return true
        }
        
        return false
    }
    
    private var completion: (() -> ())?
    
    init(completion: (() -> ())? = nil) {
        state = .created
    }
    
    func toOperation() -> Operation {
        return self
    }
    
    override func main() {
        super.main()
        state = .created
        
        DispatchQueue.global().asyncAfter(deadline: .now() + runTime) {
            self.finish()
        }
    }
    
    private func finish() {
        state = .finished(Data())
        completion?()
    }
    
    override func cancel() {
        cancelCallCount += 1
        super.cancel()
        state = .cancelled
        onCancel?()
    }
}
