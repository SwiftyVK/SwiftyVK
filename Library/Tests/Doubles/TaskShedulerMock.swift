@testable import SwiftyVK

final class TaskShedulerMock: TaskSheduler {
    
    var sheduleCallCount = 0

    func shedule(task: Task) {
        sheduleCallCount += 1
    }
}
