@testable import SwiftyVK

final class AttemptShedulerMock: AttemptSheduler {
    
    var sheduleCallCount = 0
    
    func setLimit(to: AttemptLimit) {
        
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {
        sheduleCallCount += 1
    }
}
