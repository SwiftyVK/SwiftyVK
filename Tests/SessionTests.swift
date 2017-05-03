import XCTest
@testable import SwiftyVK

final class SessionTests: BaseTestCase {
    
    
    func test_sheduleTask() {
        // Given
        let task = TaskMock()
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler
        )
        
        // Then
        session.shedule(task: task, concurrent: true)
        
        // When
        XCTAssertEqual(taskSheduler.sheduleCallCount, 1)
    }
    
    func test_sheduleAttempt() {
        // Given
        let attempt = AttemptMock()
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler
        )
        
        // Then
        try! session.shedule(attempt: attempt, concurrent: true)
        
        // When
        XCTAssertEqual(attemptSheduler.sheduleCallCount, 1)
    }
    
    func test_send() {
        // Given
        let request = Request(of: .url(""))
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler
        )
        
        // Then
        _ = session.send(request: request, callbacks: .empty)
        
        // When
        XCTAssertEqual(taskSheduler.sheduleCallCount, 1)
    }
    
    func test_createNew() {
        XCTAssertTrue(SessionImpl.new() is SessionMock)
    }
}
