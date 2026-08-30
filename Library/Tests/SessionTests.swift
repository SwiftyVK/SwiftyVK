import XCTest
@testable import SwiftyVK

final class SessionTests: XCTestCase {
    
    func test_sheduleTask_once() {
        // Given
        let context = makeContext()
        let task = TaskMock()
        // Then
        try? context.session.shedule(task: task)
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
    
    func test_sheduleAttempt_updateToken_whenExistedNotValid() throws {
        // Given
        let authExp = expectation(description: "")
        let context = makeContext()
        let attempt = AttemptMock()
        
        context.authorizator.onAuthorize = { _, _, revoke in
            let token = TokenMock(token: "", valid: !revoke)
            
            if !revoke {
                authExp.fulfill()
            }
            
            return token
        }

        // When
        try context.session.logIn(revoke: true)
        try context.session.shedule(attempt: attempt, concurrent: true)
        // Then
        waitForExpectations(timeout: 1)
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
    
    func test_session_saved_whenDestroyed() {
        // Given
        let sessionId = String.random(20)
        let context = makeContext(sessionId: sessionId)
        let exp = expectation(description: "")
        
        context.sessionSaver.onSaveState = {
            exp.fulfill()
        }
        
        // Then
        context.session.destroy()
        // When
        waitForExpectations(timeout: 1)
    }
    
    func test_session_saved_whenConfigChanged() {
        // Given
        let sessionId = String.random(20)
        let context = makeContext(sessionId: sessionId)
        let exp = expectation(description: "")
        
        context.sessionSaver.onSaveState = {
            exp.fulfill()
        }
        
        // Then
        let session = context.session
        session.config = .default
        // When
        waitForExpectations(timeout: 1)
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
    
    func test_onVKTokenCreated_calledOnce_whenTokenCreated() throws {
        // Given
        let exp = expectation(description: "")
        let context = makeContext()
        
        context.delegate.onVKTokenCreated = { _, _ in
            exp.fulfill()
        }
        
        context.authorizator.onRawAuthorize = { _, _, _ in
            return TokenMock()
        }
        // When
        try context.session.logIn(rawToken: "", expires: 0)

        // Then
        waitForExpectations(timeout: 5)
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
    
    func test_onVKTokenUpdated_calledOnce_whenTokenUpdated() throws {
        // Given
        let exp = expectation(description: "")
        let context = makeContext()
        
        context.delegate.onVKTokenUpdated = { _, _ in
            exp.fulfill()
        }
        
        context.authorizator.onRawAuthorize = { _, _, _ in
            return TokenMock(valid: false)
        }
        
        // When
        try context.session.logIn(rawToken: "", expires: 0)
        try context.session.logIn(rawToken: "", expires: 0)
        // Then
        waitForExpectations(timeout: 5)
    }
    
    func test_onVKTokenRemoved_calledOnce_whenTokenRemoved() throws {
        // Given
        let exp = expectation(description: "")
        let context = makeContext()
        
        context.delegate.onVKTokenRemoved = { _ in
            exp.fulfill()
        }
        
        context.authorizator.onRawAuthorize = { _, _, _ in
            return TokenMock()
        }
        
        // When
        try context.session.logIn(rawToken: "", expires: 0)
        context.session.logOut()
        // Then
        waitForExpectations(timeout: 5)
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
        
        context.authorizator.onAuthorize = { _, _, _ in
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
        
        context.authorizator.onAuthorize = { _, _, _ in
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
        
        context.authorizator.onAuthorize = { _, _, _ in
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
        
        context.authorizator.onAuthorize = { _, _, _ in
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
        
        context.authorizator.onAuthorize = { _, _, _ in
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
    
    func test_accessToken_and_token_equal() {
        // Given
        let context = makeContext()
        context.authorizator.onAuthorize = { _, _, _ in
            return TokenMock()
        }
        
        // When
        _ = try? context.session.logIn(revoke: false)
        
        // Then
        XCTAssert(context.session.token != nil)
        XCTAssert(context.session.token === context.session.accessToken)
    }

    #if compiler(>=5.5)
    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncLogIn_returnInfo_whenLegacyLogInSucceeds() async throws {
        // Given
        let context = makeContext()
        context.authorizator.onAuthorize = { _, _, _ in
            return TokenMock()
        }

        // When
        let actualInfo = try await context.session.logIn()

        // Then
        XCTAssertEqual(actualInfo, [:])
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncForceShare_returnData_whenLegacyForceShareSucceeds() async throws {
        // Given
        let context = makeContext()
        let expectedData = Data([1, 2, 3])
        context.sharePresenterMaker.onMake = {
            let presenter = SharePresenterMock()
            presenter.onShare = { _ in expectedData }
            return presenter
        }

        // When
        let actualData = try await context.session.forceShare(ShareContext())

        // Then
        XCTAssertEqual(actualData, expectedData)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncShare_returnData_whenLogInAndShareSucceed() async throws {
        // Given
        let context = makeContext()
        let expectedData = Data([1, 2, 3])
        context.authorizator.onAuthorize = { _, _, _ in TokenMock() }
        context.sharePresenterMaker.onMake = {
            let presenter = SharePresenterMock()
            presenter.onShare = { _ in expectedData }
            return presenter
        }

        // When
        let actualData = try await context.session.share(ShareContext())

        // Then
        XCTAssertEqual(actualData, expectedData)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncShare_throwDestroyedError_whenSessionIsDestroyed() async {
        // Given
        let context = makeContext()
        let expectedError = VKError.sessionAlreadyDestroyed(context.session)
        context.session.destroy()

        // When
        do {
            _ = try await context.session.share(ShareContext())
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), expectedError)
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_share_reportDestroyedError_onceWhenSessionIsDestroyed() {
        // Given
        let context = makeContext()
        let shareFailed = expectation(description: "share failed")
        shareFailed.assertForOverFulfill = true
        let expectedError = VKError.sessionAlreadyDestroyed(context.session)
        context.session.destroy()

        // When
        context.session.share(
            ShareContext(),
            onSuccess: { _ in XCTFail("Unexpected success") },
            onError: { error in
                XCTAssertEqual(error, expectedError)
                shareFailed.fulfill()
            }
        )

        // Then
        wait(for: [shareFailed], timeout: 1)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncLogIn_throwLegacyError_whenAuthorizatorFails() async {
        // Given
        let context = makeContext()
        let expectedError = VKError.authorizationFailed
        context.authorizator.onAuthorize = { _, _, _ in throw expectedError }

        // When
        do {
            _ = try await context.session.logIn()
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), expectedError)
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncShare_throwLegacyError_whenPresenterFails() async {
        // Given
        let context = makeContext()
        let expectedError = VKError.authorizationFailed
        context.authorizator.onAuthorize = { _, _, _ in TokenMock() }
        context.sharePresenterMaker.onMake = {
            let presenter = SharePresenterMock()
            presenter.onShare = { _ in throw expectedError }
            return presenter
        }

        // When
        do {
            _ = try await context.session.share(ShareContext())
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), expectedError)
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncLogIn_throwCancellationError_whenCancelledBeforeCallback() async {
        // Given
        let session = SessionMock()
        let logInStarted = expectation(description: "log in started")
        session.onLogIn = { _, _ in
            logInStarted.fulfill()
        }
        let logInTask = Swift.Task { () -> Error? in
            do {
                _ = try await session.logIn()
                return nil
            }
            catch {
                return error
            }
        }

        // When
        await fulfillment(of: [logInStarted], timeout: 1)
        logInTask.cancel()
        let actualError = await logInTask.value

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncShare_throwCancellationError_whenCancelledBeforeCallback() async {
        // Given
        let session = SessionMock()
        let shareStarted = expectation(description: "share started")
        session.onShare = { _, _, _ in
            shareStarted.fulfill()
        }
        let shareTask = Swift.Task { () -> Error? in
            do {
                _ = try await session.share(ShareContext())
                return nil
            }
            catch {
                return error
            }
        }

        // When
        await fulfillment(of: [shareStarted], timeout: 1)
        shareTask.cancel()
        let actualError = await shareTask.value

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncLogIn_keepCancellationError_whenSuccessArrivesLate() async {
        // Given
        let session = SessionMock()
        let lateInfo = ["late": "result"]
        let logInStarted = expectation(description: "log in started")
        var completeLogIn: (([String: String]) -> Void)?
        session.onLogIn = { onSuccess, _ in
            completeLogIn = onSuccess
            logInStarted.fulfill()
        }
        let logInTask = Swift.Task { () -> Error? in
            do {
                _ = try await session.logIn()
                return nil
            }
            catch {
                return error
            }
        }

        // When
        await fulfillment(of: [logInStarted], timeout: 1)
        logInTask.cancel()
        let actualError = await logInTask.value
        guard let completeLogIn else {
            return XCTFail("Expected login completion")
        }
        completeLogIn(lateInfo)

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncShare_keepCancellationError_whenSuccessArrivesLate() async {
        // Given
        let session = SessionMock()
        let lateData = Data([1, 2, 3])
        let shareStarted = expectation(description: "share started")
        var completeShare: ((Data) throws -> Void)?
        session.onShare = { _, onSuccess, _ in
            completeShare = onSuccess
            shareStarted.fulfill()
        }
        let shareTask = Swift.Task { () -> Error? in
            do {
                _ = try await session.share(ShareContext())
                return nil
            }
            catch {
                return error
            }
        }

        // When
        await fulfillment(of: [shareStarted], timeout: 1)
        shareTask.cancel()
        let actualError = await shareTask.value
        guard let completeShare else {
            return XCTFail("Expected share completion")
        }
        do {
            try completeShare(lateData)
        }
        catch {
            XCTFail("Unexpected error: \(error)")
        }

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncLogIn_keepCancellationError_whenErrorArrivesLate() async {
        // Given
        let session = SessionMock()
        let lateError = VKError.authorizationFailed
        let logInStarted = expectation(description: "log in started")
        var failLogIn: RequestCallbacks.Error?
        session.onLogIn = { _, onError in
            failLogIn = onError
            logInStarted.fulfill()
        }
        let logInTask = Swift.Task { () -> Error? in
            do {
                _ = try await session.logIn()
                return nil
            }
            catch {
                return error
            }
        }

        // When
        await fulfillment(of: [logInStarted], timeout: 1)
        logInTask.cancel()
        let actualError = await logInTask.value
        guard let failLogIn else {
            return XCTFail("Expected login failure callback")
        }
        failLogIn(lateError)

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncShare_keepCancellationError_whenErrorArrivesLate() async {
        // Given
        let session = SessionMock()
        let lateError = VKError.authorizationFailed
        let shareStarted = expectation(description: "share started")
        var failShare: RequestCallbacks.Error?
        session.onShare = { _, _, onError in
            failShare = onError
            shareStarted.fulfill()
        }
        let shareTask = Swift.Task { () -> Error? in
            do {
                _ = try await session.share(ShareContext())
                return nil
            }
            catch {
                return error
            }
        }

        // When
        await fulfillment(of: [shareStarted], timeout: 1)
        shareTask.cancel()
        let actualError = await shareTask.value
        guard let failShare else {
            return XCTFail("Expected share failure callback")
        }
        failShare(lateError)

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncForceShare_throwCancellationError_whenCancelledDuringPresentation() async {
        // Given
        let context = makeContext()
        let presenterStarted = expectation(description: "presenter started")
        let allowPresenterToFinish = DispatchSemaphore(value: 0)
        context.sharePresenterMaker.onMake = {
            let presenter = SharePresenterMock()
            presenter.onShare = { _ in
                presenterStarted.fulfill()
                allowPresenterToFinish.wait()
                return Data()
            }
            return presenter
        }

        defer { allowPresenterToFinish.signal() }
        let shareTask = Swift.Task { () -> Error? in
            do {
                _ = try await context.session.forceShare(ShareContext())
                return nil
            }
            catch {
                return error
            }
        }

        // When
        await fulfillment(of: [presenterStarted], timeout: 1)
        shareTask.cancel()
        let actualError = await shareTask.value

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncForceShare_keepCancellationError_whenPresenterSucceedsLate() async {
        // Given
        let context = makeContext()
        let lateData = Data([1, 2, 3])
        let presenterStarted = expectation(description: "presenter started")
        let presenterFinished = expectation(description: "presenter finished")
        let allowPresenterToFinish = DispatchSemaphore(value: 0)
        context.sharePresenterMaker.onMake = {
            let presenter = SharePresenterMock()
            presenter.onShare = { _ in
                presenterStarted.fulfill()
                allowPresenterToFinish.wait()
                presenterFinished.fulfill()
                return lateData
            }
            return presenter
        }
        defer { allowPresenterToFinish.signal() }
        let shareTask = Swift.Task { () -> Error? in
            do {
                _ = try await context.session.forceShare(ShareContext())
                return nil
            }
            catch {
                return error
            }
        }

        // When
        await fulfillment(of: [presenterStarted], timeout: 1)
        shareTask.cancel()
        let actualError = await shareTask.value
        allowPresenterToFinish.signal()
        await fulfillment(of: [presenterFinished], timeout: 1)

        // Then
        XCTAssertTrue(actualError is CancellationError)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_forceShare_reportWeakObjectError_whenPresenterMakerIsReleased() {
        // Given
        var session: SessionImpl?
        do {
            let context = makeContext()
            session = context.session
        }
        guard let session else {
            return XCTFail("Expected session")
        }
        let shareFailed = expectation(description: "share failed")

        // When
        session.forceShare(
            ShareContext(),
            onSuccess: { _ in XCTFail("Unexpected success") },
            onError: { error in
                XCTAssertEqual(error, .weakObjectWasDeallocated)
                shareFailed.fulfill()
            }
        )

        // Then
        wait(for: [shareFailed], timeout: 1)
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_asyncForceShare_throwWeakObjectError_whenPresenterMakerIsReleased() async {
        // Given
        var session: SessionImpl?
        do {
            let context = makeContext()
            session = context.session
        }
        guard let session else {
            return XCTFail("Expected session")
        }

        // When
        do {
            _ = try await session.forceShare(ShareContext())
            XCTFail("Expected an error")
        }
        catch {
            // Then
            XCTAssertEqual(error.toVK(), .weakObjectWasDeallocated)
        }
    }

    @available(iOS 13.0, macOS 10.15, *)
    func test_share_reportWeakObjectError_whenSessionIsReleasedAfterLogIn() {
        // Given
        let authorizator: AuthorizatorMock
        let sharePresenterMaker: SharePresenterMakerMock
        var session: SessionImpl?
        do {
            let context = makeContext()
            authorizator = context.authorizator
            sharePresenterMaker = context.sharePresenterMaker
            session = context.session
        }
        let authorizationStarted = expectation(description: "authorization started")
        let shareFailed = expectation(description: "share failed")
        let allowAuthorizationToFinish = DispatchSemaphore(value: 0)
        authorizator.onAuthorize = { _, _, _ in
            authorizationStarted.fulfill()
            allowAuthorizationToFinish.wait()
            return TokenMock()
        }
        _ = sharePresenterMaker

        defer { allowAuthorizationToFinish.signal() }

        // When
        do {
            guard let session else {
                return XCTFail("Expected session")
            }
            session.share(
                ShareContext(),
                onSuccess: { _ in XCTFail("Unexpected success") },
                onError: { error in
                    XCTAssertEqual(error, .weakObjectWasDeallocated)
                    shareFailed.fulfill()
                }
            )
        }

        wait(for: [authorizationStarted], timeout: 1)
        session = nil
        allowAuthorizationToFinish.signal()

        // Then
        wait(for: [shareFailed], timeout: 1)
    }

    #endif

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
    sharePresenterMaker: SharePresenterMakerMock,
    sessionSaver: SessionsHolderMock
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
            sharePresenterMaker,
            sessionSaver
        )
}
