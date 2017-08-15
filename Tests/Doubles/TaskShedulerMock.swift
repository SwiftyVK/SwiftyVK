@testable import SwiftyVK

final class TaskShedulerMock: TaskSheduler {
    
    var sheduleCallCount = 0
    var shouldThrows = false

    func shedule(task: Task, concurrent: Bool) throws {
        if shouldThrows {
            throw RequestError.wrongTaskType.asVk
        }
        
        sheduleCallCount += 1
    }
}
