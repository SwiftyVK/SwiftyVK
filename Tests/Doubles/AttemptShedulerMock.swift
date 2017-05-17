@testable import SwiftyVK

final class AttemptShedulerMock: AttemptSheduler {
    
    var limit = AttemptLimit.unlimited
    var sheduleCallCount = 0
    
    func setLimit(to newLimit: AttemptLimit) {
        limit = newLimit
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {        
        sheduleCallCount += 1
    }
}
