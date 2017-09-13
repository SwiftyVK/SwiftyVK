import XCTest
@testable import SwiftyVK

final class SessionTests: XCTestCase {
    
    private func syncLogIn(
        session: Session,
        onSuccess: @escaping ([String : String]) -> (),
        onError: @escaping (VKError)-> ()
        ) {
        let exp = expectation(description: "")
        
        session.logIn(
            onSuccess: { info in
                onSuccess(info)
                exp.fulfill()
            },
            onError: { error in
                onError(error)
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: 10)
    }
    
    func test_sheduleTask_once() {
        // Given
        let context = makeContext()
        let task = TaskMock()
        // Then
        try? context.session.shedule(task: task, concurrent: true)
        // When
        XCTAssertEqual(context.taskSheduler.sheduleCallCount, 1)
    }
    
    func test_sheduleAttempt_once() {
        // Given
        let context = makeContext()
        let attempt = AttemptMock()
        // Then
        try! context.session.shedule(attempt: attempt, concurrent: true)
        // When
        XCTAssertEqual(context.attemptSheduler.sheduleCallCount, 1)
    }
    
    func test_send_once() {
        // Given
        let context = makeContext()
        let request = Request(type: .url("")).toMethod()
        // Then
        _ = context.session.send(method: request)
        // When
        XCTAssertEqual(context.taskSheduler.sheduleCallCount, 1)
    }
    
    func test_shedulerLimitChanged_whenSetNew() {
        // Given
        let context = makeContext()
        // When
        context.session.config.attemptsPerSecLimit = 1
        // Then
        XCTAssertEqual(context.attemptSheduler.limit.count, 1)
    }
    
    func test_configChanged_whenSetNew() {
        // Given
        let context = makeContext()
        // When
        context.session.config = SessionConfig(attemptsPerSecLimit: 1)
        // Then
        XCTAssertEqual(context.attemptSheduler.limit.count, 1)
    }
    
    func test_logIn_shouldBeAuthorized_whenAuthorizatorReturnsToken() {
        // Given
        let context = makeContext()

        context.authorizator.onAuthorize = { _, _, _ in
            return TokenMock()
        }
        // When
        syncLogIn(
            session: context.session,
            onSuccess: { info in
            },
            onError: { error in
                XCTFail("\(error)")
            }
        )
        
        // Then
        XCTAssertEqual(context.session.state, .authorized)
        XCTAssertEqual(context.authorizator.authorizeCallCount, 1)
    }
    
    func test_logIn_shouldBeFail_whenAuthorizatorThrowsError() {
        // Given
        let context = makeContext()

        context.authorizator.onAuthorize = { _, _, _ in
            throw VKError.authorizationFailed
        }
        // When
        syncLogIn(
            session: context.session,
            onSuccess: { info in
                XCTFail("Log in sould be fail")
            },
            onError: { error in
                XCTAssertEqual(error.asVK, VKError.authorizationFailed)
            }
        )
        
        XCTAssertEqual(context.session.state, .initiated)
        XCTAssertEqual(context.authorizator.authorizeCallCount, 1)
    }
    
    func test_logIn_shouldBeFail_whenAuthorizatorThrowsUnknownError() {
        // Given
        let context = makeContext()

        context.authorizator.onAuthorize = { _, _, _ in
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        // When
        syncLogIn(
            session: context.session,
            onSuccess: { info in
                XCTFail("Log in sould be fail")
            },
            onError: { error in
                XCTAssertEqual((error as NSError).code, 0)
            }
        )
        
        XCTAssertEqual(context.session.state, .initiated)
        XCTAssertEqual(context.authorizator.authorizeCallCount, 1)
    }
    
    func test_logIn_shouldBeFail_whenSessionDestroyed() {
        // Given
        let context = makeContext()
        // When
        context.session.destroy()
        
        syncLogIn(
            session: context.session,
            onSuccess: { info in
                XCTFail("Log in sould be fail")
            },
            onError: { error in
                XCTAssertEqual(error.asVK, VKError.sessionAlreadyDestroyed(context.session))
            }
        )
        // Then
        XCTAssertEqual(context.session.state, .destroyed)
    }
    
    func test_logInWithRawToken_shouldBeFail_whenSessionDestroyed() {
        // Given
        let context = makeContext()
        // When
        context.session.destroy()
        
        do {
            try context.session.logIn(rawToken: "", expires: 0)
            XCTFail("Log in sould be fail")
        } catch let error {
            XCTAssertEqual(error.asVK, VKError.sessionAlreadyDestroyed(context.session))
        }
        // Then
        XCTAssertEqual(context.session.state, .destroyed)
    }
    
    func test_logInWithRawToken() {
        // Given
        let context = makeContext()
        // When
        
        do {
            try context.session.logIn(rawToken: "", expires: 0)
        } catch let error {
            XCTFail("\(error)")
        }
        // Then
        XCTAssertEqual(context.session.state, .authorized)
        XCTAssertEqual(context.authorizator.authorizeWithRawTokenCallCount, 1)
    }
    
    func test_logOut() {
        // Given
        let context = makeContext()

        context.authorizator.onAuthorize = { _, _, _ in
            return TokenMock()
        }
        // When
        syncLogIn(
            session: context.session,
            onSuccess: { info in
            },
            onError: { error in
                XCTFail("\(error)")
            }
        )
        
        context.session.logOut()
        // Then
        XCTAssertEqual(context.session.state, .initiated)
    }
    
    func test_logOut_withoutToken() {
        // Given
        let context = makeContext()
        // When
        context.session.logOut()
        // Then
        XCTAssertEqual(context.session.state, .initiated)
    }
    
    func test_sendTask_whenSessionDestroyed() {
        // Given
        let context = makeContext()
        let request = Request(type: .url("")).toMethod().onError { error in
            XCTAssertEqual(error.asVK, VKError.sessionAlreadyDestroyed(context.session))
        }
        // When
        context.session.id = ""
        context.session.send(method: request)
    }
    
    func test_destroy() {
        // Given
        let context = makeContext()
        // When
        context.session.destroy()
        // Then
        XCTAssertEqual(context.session.state, .destroyed)
    }
}

private func makeContext() -> (session: SessionImpl, taskSheduler: TaskShedulerMock, attemptSheduler: AttemptShedulerMock, authorizator: AuthorizatorMock) {
    let taskSheduler = TaskShedulerMock()
    let attemptSheduler = AttemptShedulerMock()
    let authorizator = AuthorizatorMock()
    let taskMaker = TaskMakerMock()
    let captchaPresenter = CaptchaPresenterMock()
    let sessionSaver = SessionsHolderMock()
    let delegate = SwiftyVKDelegateMock()
    let longPollMaker = LongPollMakerMock()
    
    let session = SessionImpl(
        id: .random(20),
        config: .default,
        taskSheduler: taskSheduler,
        attemptSheduler: attemptSheduler,
        authorizator: authorizator,
        taskMaker: taskMaker,
        captchaPresenter: captchaPresenter,
        sessionSaver: sessionSaver,
        longPollMaker: longPollMaker,
        delegate: delegate
    )
    
    return (session, taskSheduler, attemptSheduler, authorizator)
}
