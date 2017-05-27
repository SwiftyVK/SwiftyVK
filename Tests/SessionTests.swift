import XCTest
@testable import SwiftyVK

final class SessionTests: BaseTestCase {
    
    var sessionObjects: (SessionImpl, TaskShedulerMock, AttemptShedulerMock, AuthorizatorMock) {
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        let authorizator = AuthorizatorMock()
        
        let session = SessionImpl(
            taskSheduler: taskSheduler,
            attemptSheduler: attemptSheduler,
            authorizator: authorizator,
            taskMaker: dependencyBoxMock
        )
        
        return (session, taskSheduler, attemptSheduler, authorizator)
    }
    
    func test_sheduleTask() {
        // Given
        let (session, taskSheduler, _, _) = sessionObjects
        let task = TaskMock()
        // Then
        try? session.shedule(task: task, concurrent: true)
        // When
        XCTAssertEqual(taskSheduler.sheduleCallCount, 1)
    }
    
    func test_sheduleAttempt() {
        // Given
        let (session, _, attemptSheduler, _) = sessionObjects
        let attempt = AttemptMock()
        // Then
        try! session.shedule(attempt: attempt, concurrent: true)
        // When
        XCTAssertEqual(attemptSheduler.sheduleCallCount, 1)
    }
    
    func test_send() {
        // Given
        let (session, taskSheduler, _, _) = sessionObjects
        let request = Request(of: .url(""))
        // Then
        _ = session.send(request: request, callbacks: .empty)
        // When
        XCTAssertEqual(taskSheduler.sheduleCallCount, 1)
    }
    
    func test_updateTaskShedulerLimit() {
        // Given
        let (session, _, attemptSheduler, _) = sessionObjects
        // When
        session.config.attemptsPerSecLimit = .limited(1)
        // Then
        XCTAssertEqual(attemptSheduler.limit.count, AttemptLimit.limited(1).count)
    }
    
    func test_updateConfig() {
        // Given
        let (session, _, attemptSheduler, _) = sessionObjects
        // When
        session.config = SessionConfig(attemptsPerSecLimit: .limited(1))
        // Then
        XCTAssertEqual(attemptSheduler.limit.count, AttemptLimit.limited(1).count)
    }
    
    func test_logIn_shouldBeSuccess() {
        // Given
        let (session, _, _, authorizator) = sessionObjects
        // When
        do {
            try session.logIn()
        } catch let error {
            XCTFail("\(error)")
        }
        // Then
        XCTAssertEqual(session.state, .authorized)
        XCTAssertEqual(authorizator.authorizeCallCount, 1)
    }
    
    func test_logIn_shouldBeFail_whenAuthorizatorThrows() {
        // Given
        let (session, _, _, authorizator) = sessionObjects
        // When
        authorizator.authorizeShouldThrows = true
        
        do {
            try session.logIn()
            XCTFail("Log in sould be fail")
        } catch let error {
            XCTAssertEqual(error as? SessionError, .failedAuthorization)
        }
        // Then
        XCTAssertEqual(session.state, .initiated)
        XCTAssertEqual(authorizator.authorizeCallCount, 1)
    }
    
    func test_logIn_shouldBeFail_whenSessionDestroyed() {
        // Given
        let (session, _, _, _) = sessionObjects
        // When
        session.destroy()
        
        do {
            try session.logIn()
            XCTFail("Log in sould be fail")
        } catch let error {
            XCTAssertEqual(error as? SessionError, .sessionDestroyed)
        }
        // Then
        XCTAssertEqual(session.state, .destroyed)
    }
    
    func test_logInWithRawToken_shouldBeFail_whenSessionDestroyed() {
        // Given
        let (session, _, _, _) = sessionObjects
        // When
        session.destroy()
        
        do {
            try session.logIn()
            XCTFail("Log in sould be fail")
        } catch let error {
            XCTAssertEqual(error as? SessionError, .sessionDestroyed)
        }
        // Then
        XCTAssertEqual(session.state, .destroyed)
    }
    
    func test_logInWithRawToken() {
        // Given
        let (session, _, _, authorizator) = sessionObjects
        // When
        
        do {
            try session.logInWith(rawToken: "", expires: 0)
        } catch let error {
            XCTFail("\(error)")
        }
        // Then
        XCTAssertEqual(session.state, .authorized)
        XCTAssertEqual(authorizator.authorizeWithRawTokenCallCount, 1)
    }
    
    func test_logOut() {
        // Given
        let (session, _, _, _) = sessionObjects
        // When
        do {
            try session.logInWith(rawToken: "", expires: 0)
        } catch let error {
            XCTFail("\(error)")
        }
        
        session.logOut()
        // Then
        XCTAssertEqual(session.state, .initiated)
    }
    
    func test_logOut_withoutToken() {
        // Given
        let (session, _, _, _) = sessionObjects
        // When
        session.logOut()
        // Then
        XCTAssertEqual(session.state, .initiated)
    }
    
    func test_sendTask_whenSessionDestroyed() {
        // Given
        let (session, _, _, _) = sessionObjects
        let request = Request(of: .url(""))
        // When
        session.id = ""

        session.send(
            request: request,
            callbacks: Callbacks(
                onError: { error in
                    // Then
                    XCTAssertEqual(error as? SessionError, .sessionDestroyed)
            })
        )
    }
    
    func test_sendWrongTask_shouldBeFail() {
        // Given
        let (session, taskSheduler, _, _) = sessionObjects
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
    
    func test_destroy() {
        // Given
        let (session, _, _, _) = sessionObjects
        // When
        session.destroy()
        // Then
        XCTAssertEqual(session.state, .destroyed)
    }
}
