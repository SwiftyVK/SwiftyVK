import XCTest
@testable import SwiftyVK

final class SessionTests: BaseTestCase {
    
    
    var sessionObjects: (SessionImpl, TaskShedulerMock, AttemptShedulerMock) {
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler,
            authorizatorMaker: dependencyBoxMock,
            taskMaker: dependencyBoxMock
        )
        
        return (session, taskSheduler, attemptSheduler)
    }
    
    func test_sheduleTask() {
        // Given
        let (session, taskSheduler, _) = sessionObjects
        let task = TaskMock()
        // Then
        try? session.shedule(task: task, concurrent: true)
        // When
        XCTAssertEqual(taskSheduler.sheduleCallCount, 1)
    }
    
    func test_sheduleAttempt() {
        // Given
        let (session, _, attemptSheduler) = sessionObjects
        let attempt = AttemptMock()
        // Then
        try! session.shedule(attempt: attempt, concurrent: true)
        // When
        XCTAssertEqual(attemptSheduler.sheduleCallCount, 1)
    }
    
    func test_send() {
        // Given
        let (session, taskSheduler, _) = sessionObjects
        let request = Request(of: .url(""))
        // Then
        _ = session.send(request: request, callbacks: .empty)
        // When
        XCTAssertEqual(taskSheduler.sheduleCallCount, 1)
    }
    
    func test_updateTaskShedulerLimit() {
        // Given
        let (session, _, attemptSheduler) = sessionObjects
        // When
        session.config.attemptsPerSecLimit = .limited(1)
        // Then
        XCTAssertEqual(attemptSheduler.limit.count, AttemptLimit.limited(1).count)
    }
    
    func test_updateConfig() {
        // Given
        let (session, _, attemptSheduler) = sessionObjects
        // When
        session.config = SessionConfig(attemptsPerSecLimit: .limited(1))
        // Then
        XCTAssertEqual(attemptSheduler.limit.count, AttemptLimit.limited(1).count)
    }
    
    func test_activate() {
        // Given
        let (session, _, _) = sessionObjects
        // When
        try? session.activate(appId: "", callbacks: .default)
        // Then
        XCTAssertEqual(session.state, .activated)
    }
    
    func test_activate_whenAlreadyActivated() {
        // Given
        let (session, _, _) = sessionObjects
        // When
        try? session.activate(appId: "", callbacks: .default)
        
        do {
            try session.activate(appId: "", callbacks: .default)
        } catch let error {
            // Then
            XCTAssertEqual(error as? SessionError, .alreadyActivated)
            XCTAssertEqual(session.state, .activated)
        }
    }
    
    func test_sendTask_whenSessionDead() {
        // Given
        let (session, _, _) = sessionObjects
        let request = Request(of: .url(""))
        // When
        session.state = .dead

        session.send(
            request: request,
            callbacks: Callbacks(
                onError: { error in
                    // Then
                    XCTAssertEqual(error as? SessionError, .sessionIsDead)
            })
        )
    }
    
    func test_sendWrongTask() {
        // Given
        let (session, taskSheduler, _) = sessionObjects
        let request = Request(of: .url(""))
        // When
        taskSheduler.shouldThrows = true

        session.send(
            request: request,
            callbacks: Callbacks(
                onError: { error in
                    // Then
                    XCTAssertEqual(error as? RequestError, .wrongTaskType)
            })
        )
    }
}
