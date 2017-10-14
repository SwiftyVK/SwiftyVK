@testable import SwiftyVK

final class TaskShedulerMock: TaskSheduler {
    
    var sheduleCallCount = 0

    func shedule(task: Task, concurrent: Bool) {
        sheduleCallCount += 1
    }
}
