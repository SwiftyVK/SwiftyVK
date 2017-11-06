import XCTest
@testable import SwiftyVK

final class SessionTests: XCTestCase {
    
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
    
    func test_sendTask_once() {
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

        context.authorizator.onAuthorize = { _, _, _, _ in
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

        context.authorizator.onAuthorize = { _, _, _, _ in
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

        context.authorizator.onAuthorize = { _, _, _, _ in
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
    
    func test_logInWithRawToken_shouldBeFail_whenAlreadyAuthorized() {
        // Given
        let context = makeContext()
        
        context.authorizator.onRawAuthorize = { _, _, _ in
            return TokenMock()
        }
        // When
        do {
            try context.session.logIn(rawToken: "", expires: 0)
            try context.session.logIn(rawToken: "", expires: 0)
            XCTFail("Log in sould be fail")
        } catch let error {
            // Then
            XCTAssertEqual(context.session.state, .authorized)
            XCTAssertEqual(error.asVK, VKError.sessionAlreadyAuthorized(context.session))
        }
        // Then
        XCTAssertEqual(context.session.state, .authorized)
    }
    
    func test_state_isAuthorized_whenSessionRestored() {
        // Given
        let sessionId = String.random(20)
        let context = makeContext(sessionId: sessionId)
        
        context.authorizator.onGetSavedToken = { givenSessionId in
            XCTAssertEqual(givenSessionId, sessionId)
            return TokenMock()
        }
        
        // Then
        let state = context.makeSession().state
        // When
        XCTAssertEqual(state, .authorized)
    }
    
    func test_state_isInitiated_whenSessionNotRestored() {
        // Given
        let sessionId = String.random(20)
        let context = makeContext(sessionId: sessionId)
        
        // Then
        let state = context.makeSession().state
        // When
        XCTAssertEqual(state, .initiated)
    }
    
    func test_onVKTokenCreated_calledOnce_whenTokenCreated() {
        // Given
        let context = makeContext()
        var onVKTokenCreatedCallCount = 0
        
        context.delegate.onVKTokenCreated = { _, _ in
            onVKTokenCreatedCallCount += 1
        }
        
        context.authorizator.onRawAuthorize = { _, _, _ in
            return TokenMock()
        }
        // When
        do {
            try context.session.logIn(rawToken: "", expires: 0)
        } catch let error {
            XCTFail("Unexpected error \(error)")
        }
        // Then
        XCTAssertEqual(onVKTokenCreatedCallCount, 1)
    }
    
    func test_onVKTokenCreated_callOnce_whenSessionRestored() {
        // Given
        let sessionId = String.random(20)
        let context = makeContext(sessionId: sessionId)
        let exp = expectation(description: "")
        
        context.authorizator.onGetSavedToken = { givenSessionId in
            XCTAssertEqual(givenSessionId, sessionId)
            return TokenMock()
        }
        
        context.delegate.onVKTokenCreated = { givenSessionId, info in
            XCTAssertEqual(givenSessionId, sessionId)
            exp.fulfill()
        }
        
        // Then
        _ = context.makeSession()
        // When
        waitForExpectations(timeout: 5)
    }
    
    func test_onVKTokenUpdated_calledOnce_whenTokenUpdated() {
        // Given
        let context = makeContext()
        var onVKTokenUpdatedCallCount = 0
        
        context.delegate.onVKTokenUpdated = { _, _ in
            onVKTokenUpdatedCallCount += 1
        }
        
        context.authorizator.onRawAuthorize = { _, _, _ in
            return TokenMock(valid: false)
        }
        
        // When
        do {
            try context.session.logIn(rawToken: "", expires: 0)
            try context.session.logIn(rawToken: "", expires: 0)
        } catch let error {
            XCTFail("Unexpected error \(error)")
        }
        // Then
        XCTAssertEqual(onVKTokenUpdatedCallCount, 1)
    }
    
    func test_onVKTokenRemoved_calledOnce_whenTokenRemoved() {
        // Given
        let context = makeContext()
        var onVKDidLogOutCallCount = 0
        
        context.delegate.onVKTokenRemoved = { _ in
            onVKDidLogOutCallCount += 1
        }
        
        context.authorizator.onRawAuthorize = { _, _, _ in
            return TokenMock()
        }
        
        // When
        do {
            try context.session.logIn(rawToken: "", expires: 0)
            context.session.logOut()
        } catch let error {
            XCTFail("Unexpected error \(error)")
        }
        // Then
        XCTAssertEqual(onVKDidLogOutCallCount, 1)
    }
    
    func test_logInWithRawToken() {
        // Given
        let context = makeContext()
        
        context.authorizator.onRawAuthorize = { _, _, _ in
            return TokenMock()
        }
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

        context.authorizator.onAuthorize = { _, _, _, _ in
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
        XCTAssertEqual(context.session.state, .destroyed)
    }
    
    func test_logOut_withoutToken() {
        // Given
        let context = makeContext()
        // When
        context.session.logOut()
        // Then
        XCTAssertEqual(context.session.state, .destroyed)
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
    
    func test_destroy_changesStateToDestroyed() {
        // Given
        let context = makeContext()
        // When
        context.session.destroy()
        // Then
        XCTAssertEqual(context.session.state, .destroyed)
    }
    
    func test_validate_changesStateToAuthorized() {
        // Given
        let context = makeContext()
        
        context.authorizator.onAuthorize = { _, _, _, _ in
            return TokenMock()
        }
        
        context.authorizator.onValidate = { _, _ in
            return TokenMock()
        }
        // When
        do {
            _ = try context.session.logIn(revoke: false)
            try context.session.validate(redirectUrl: URL(fileURLWithPath: ""))
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
        // Then
        XCTAssertEqual(context.session.state, .authorized)
    }
    
    func test_captcha_isPresentedOnce() {
        // Given
        var onPresentCallCount = 0
        let context = makeContext()
        
        context.authorizator.onAuthorize = { _, _, _, _ in
            return TokenMock()
        }
        
        context.captchaPresenter.onPresent = {
            onPresentCallCount += 1
            return ""
        }
        // When
        do {
            _ = try context.session.logIn(revoke: false)
            _ = try context.session.captcha(rawUrlToImage: "")
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
        // Then
        XCTAssertEqual(onPresentCallCount, 1)
    }
    
    func test_dismissCaptcha_isDismissedOnce() {
        // Given
        var onDismissCallCount = 0
        let context = makeContext()
        
        context.captchaPresenter.onDismiss = {
            onDismissCallCount += 1
        }
        // When
        context.session.dismissCaptcha()
        // Then
        XCTAssertEqual(onDismissCallCount, 1)
    }
    
    func test_share_presenterCalled_whenSessionAuthorized() {
        // Given
        let context = makeContext()
        let shareContext = ShareContext()
        var shareCallCount = 0
        let exp = self.expectation(description: "")
        
        context.authorizator.onAuthorize = { _, _, _, _ in
            return TokenMock()
        }
        
        context.sharePresenterMaker.onMake = {
            let presenter = SharePresenterMock()
            presenter.onShare = { _shareContext in
                // Then
                XCTAssertEqual(_shareContext, shareContext)
                shareCallCount += 1
                exp.fulfill()
                return Data()
            }
            return presenter
        }
        // When
        _ = try? context.session.logIn(revoke: false)
        
        context.session.share(
            shareContext,
            onSuccess: { _ in },
            onError: { _ in }
        )
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertEqual(shareCallCount, 1)
    }
    
    func test_share_shareCalled_whenSessionAuthorizedOnSharing() {
        // Given
        let context = makeContext()
        let shareContext = ShareContext()
        var shareCallCount = 0
        let exp = self.expectation(description: "")
        
        context.authorizator.onAuthorize = { _, _, _, _ in
            return TokenMock()
        }
        
        context.sharePresenterMaker.onMake = {
            let presenter = SharePresenterMock()
            presenter.onShare = { _shareContext in
                // Then
                XCTAssertEqual(_shareContext, shareContext)
                shareCallCount += 1
                exp.fulfill()
                return Data()
            }
            return presenter
        }
        // When
        context.session.share(
            shareContext,
            onSuccess: { _ in },
            onError: { _ in }
        )
        // Then
        waitForExpectations(timeout: 5)
        XCTAssertEqual(shareCallCount, 1)
    }
    
    func test_share_shareReturnsError_whenSessionNotAuthorizedOnSharing() {
        // Given
        let context = makeContext()
        let shareContext = ShareContext()
        let exp = self.expectation(description: "")
        
        context.authorizator.onAuthorize = { _, _, _, _ in
            throw VKError.cantParseTokenInfo("")
        }
        
        // When
        context.session.share(
            shareContext,
            onSuccess: { _ in },
            onError: {
                // Then
                XCTAssertEqual($0, VKError.cantParseTokenInfo(""))
                exp.fulfill()
            }
        )
        
        waitForExpectations(timeout: 5)
    }
    
    func test_share_presenterNotCalled_whenSessionDestroyed() {
        // Given
        let context = makeContext()
        let shareContext = ShareContext()
        context.session.destroy()
        
        context.sharePresenterMaker.onMake = {
            // Then
            XCTFail("Session already destroyed")
            return SharePresenterMock()
        }
        // When
        context.session.share(
            shareContext,
            onSuccess: { _ in },
            onError: { _ in }
        )
    }
    
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
    
}

private func makeContext(sessionId: String? = nil) -> (
    makeSession: () -> SessionImpl,
    session: SessionImpl,
    taskSheduler: TaskShedulerMock,
    attemptSheduler: AttemptShedulerMock,
    authorizator: AuthorizatorMock,
    captchaPresenter: CaptchaPresenterMock,
    delegate: SwiftyVKDelegateMock,
    sharePresenterMaker: SharePresenterMakerMock
    ) {
        let taskSheduler = TaskShedulerMock()
        let attemptSheduler = AttemptShedulerMock()
        let authorizator = AuthorizatorMock()
        let taskMaker = TaskMakerMock()
        let captchaPresenter = CaptchaPresenterMock()
        let sharePresenterMaker = SharePresenterMakerMock()
        let sessionSaver = SessionsHolderMock()
        let delegate = SwiftyVKDelegateMock()
        let longPollMaker = LongPollMakerMock()
        
        let makeSession = {
            SessionImpl(
                id: sessionId ?? .random(20),
                config: .default,
                taskSheduler: taskSheduler,
                attemptSheduler: attemptSheduler,
                authorizator: authorizator,
                taskMaker: taskMaker,
                captchaPresenter: captchaPresenter,
                sharePresenterMaker: sharePresenterMaker,
                sessionSaver: sessionSaver,
                longPollMaker: longPollMaker,
                delegate: delegate
            )
        }
        
        return (
            makeSession,
            makeSession(),
            taskSheduler,
            attemptSheduler,
            authorizator,
            captchaPresenter,
            delegate,
            sharePresenterMaker
        )
}
