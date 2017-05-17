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
            attemptSheduler: attemptSheduler, createTask: dependencyBoxMock.task
        )
        
        // Then
        try? session.shedule(task: task, concurrent: true)
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
            attemptSheduler: attemptSheduler, createTask: dependencyBoxMock.task
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
            attemptSheduler: attemptSheduler, createTask: dependencyBoxMock.task
        )
        // Then
        _ = session.send(request: request, callbacks: .empty)
        // When
        XCTAssertEqual(taskSheduler.sheduleCallCount, 1)
    }
    
    func test_updateTaskShedulerLimit() {
        // Given
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler, createTask: dependencyBoxMock.task
        )
        // When
        session.config.attemptsPerSecLimit = .limited(1)
        // Then
        XCTAssertEqual(attemptSheduler.limit.count, AttemptLimit.limited(1).count)
    }
    
    func test_updateConfig() {
        // Given
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler, createTask: dependencyBoxMock.task
        )
        // When
        session.config = SessionConfig(attemptsPerSecLimit: .limited(1))
        // Then
        XCTAssertEqual(attemptSheduler.limit.count, AttemptLimit.limited(1).count)
    }
    
    func test_activate() {
        // Given
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler, createTask: dependencyBoxMock.task
        )
        // When
        try? session.activate(appId: "", callbacks: .default)
        // Then
        XCTAssertEqual(session.state, .activated)
    }
    
    func test_activate_whenAlreadyActivated() {
        // Given
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler, createTask: dependencyBoxMock.task
        )
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
        let request = Request(of: .url(""))
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler, createTask: dependencyBoxMock.task
        )
        
        session.state = .dead
        // When
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
        let request =  Request(of: .url(""))
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler, createTask: dependencyBoxMock.task
        )
        
        taskSheduler.shouldThrows = true
        // When
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
