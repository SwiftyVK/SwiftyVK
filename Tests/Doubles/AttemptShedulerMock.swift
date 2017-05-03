@testable import SwiftyVK

final class AttemptShedulerMock: AttemptSheduler {
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {}
}
