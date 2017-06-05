import XCTest
@testable import SwiftyVK

class AuthorizatorTests: BaseTestCase {

    func makeContext() -> (
        authorizator: AuthorizatorImpl,
        delegate: SwiftyVKDelegateMock,
        storage: TokenStorageMock,
        tokenMaker: TokenMakerMock,
        parser: TokenParserMock,
        vkApp: VkAppProxyMock,
        webPresenterMaker: WebPresenterMakerMock,
        session: SessionMock
        ) {
        let delegate = SwiftyVKDelegateMock()
        let storage = TokenStorageMock()
        let tokenMaker = TokenMakerMock()
        let parser = TokenParserMock()
        let vkApp = VkAppProxyMock()
        let webPresenterMaker = WebPresenterMakerMock()
        let session = SessionMock()
        
        let authorizator = AuthorizatorImpl(
            appId: "1234567890",
            delegate: delegate,
            tokenStorage: storage,
            tokenMaker: tokenMaker,
            tokenParser: parser,
            vkAppProxy: vkApp,
            webPresenterMaker: webPresenterMaker
        )
        
        return (authorizator, delegate, storage, tokenMaker, parser, vkApp, webPresenterMaker, session)
    }
    
    
    func test_authorize_withTokenfromStorage() {
        // Given
        let context = makeContext()
        
        context.storage.onGet = { _ in
            return TokenMock()
        }
        
        context.vkApp.onSend = { _ in
            XCTFail("Token should be returned from storage")
            return false
        }
        // When
        let token = try? context.authorizator.authorize(session: context.session, revoke: false)
        // Then
        XCTAssertNotNil(token)
    }
    
    func test_authorize_withErrorOnCreatePresenter() {
        // Given
        let context = makeContext()
        
        context.webPresenterMaker.onMake = nil
        // When
        do {
            _ = try context.authorizator.authorize(session: context.session, revoke: false)
            // Then
            XCTFail("Code above should throw error")
        } catch let error {
            XCTAssertEqual(error as? SessionError, SessionError.cantMakeWebViewController)
        }
    }
    
    func test_authorize_errorOnParseToken() {
        // Given
        let context = makeContext()
        
        context.webPresenterMaker.onMake = {
            return WebPresenterMock()
        }
        // When
        do {
            _ = try context.authorizator.authorize(session: context.session, revoke: false)
            // Then
            XCTFail("Code above should throw error")
        } catch let error {
            XCTAssertEqual(error as? SessionError, SessionError.cantParseToken)
        }
    }
    
    func test_authorize_withSucessfullCreatedToken() {
        // Given
        let context = makeContext()
        
        context.webPresenterMaker.onMake = {
            return WebPresenterMock()
        }
        
        context.parser.onParse = { _ in
            return ("token", expires: 123, [:])
        }
        // When
        let token = try? context.authorizator.authorize(session: context.session, revoke: false)
        // Then
        XCTAssertNotNil(token)
    }
    
    func test_authorize_withDelegateWillLoginCallCount() {
        // Given
        let context = makeContext()
        var delegateCallCount = 0
        
        context.delegate.onVkWillLogIn = { _ in
            delegateCallCount += 1
            return []
        }
        // When
        _ = try? context.authorizator.authorize(session: context.session, revoke: true)
        // Then
        XCTAssertEqual(delegateCallCount, 2)
    }
    
    func test_authorize_withRawToken_tokenMakerShouldCalledOnce() {
        // Given
        let context = makeContext()
        var delegateCallCount = 0
        
        context.tokenMaker.onMake = { token, expires, info in
            XCTAssertEqual(token, "1234567890")
            XCTAssertEqual(expires, 123)
            XCTAssertEqual(info, [:])
            
            delegateCallCount += 1
            return TokenMock(token: "1234567890")
        }
        // When
        _ = try? context.authorizator.authorize(session: context.session, rawToken: "1234567890", expires: 123)
        // Then
        XCTAssertEqual(delegateCallCount, 1)
    }
    
    func test_authoriz_withRawToken_storageShoulSevedOnce() {
        // Given
        let context = makeContext()
        var saveCallCount = 0
        
        context.tokenMaker.onMake = { token, expires, info in
            return TokenMock(token: "1234567890")
        }
        
        context.storage.onSave = { token, sessionId in
            XCTAssertEqual(token.get(), "1234567890")
            XCTAssertEqual(context.session.id, sessionId)

            saveCallCount += 1
        }
        // When
        _ = try? context.authorizator.authorize(session: context.session, rawToken: "1234567890", expires: 123)
        // Then
        XCTAssertEqual(saveCallCount, 1)
    }
    
    func test_reset_returnedTokenShouldBeNil() {
        // Given
        let context = makeContext()
        // When
        let token = context.authorizator.reset(session: context.session)
        // Then
        XCTAssertNil(token)
    }
    
    func test_reset_storageShouldRemoveOnce() {
        // Given
        let context = makeContext()
        var removeCallCount = 0
        
        context.storage.onRemove = { sessionId in
            XCTAssertEqual(context.session.id, sessionId)
            removeCallCount += 1
        }
        // When
        _ = context.authorizator.reset(session: context.session)
        // Then
        XCTAssertEqual(removeCallCount, 1)
    }
    
    func test_reset_delegeteShouldCallLogoutOnce() {
        // Given
        let context = makeContext()
        var delegateCallCount = 0
        
        context.delegate.onVkDidLogOut = { session in
            XCTAssertEqual(context.session.id, session.id)
            delegateCallCount += 1
        }
        // When
        _ = context.authorizator.reset(session: context.session)
        // Then
        XCTAssertEqual(delegateCallCount, 1)
    }
    
    func test_handle_withNilResponse_shouldCantHandle() {
        // Given
        let context = makeContext()
        
        context.vkApp.onHandle = { url, string in
            return nil
        }
        // When
        context.authorizator.handle(url: URL(string: "http://examp.le")!, app: "")
        // Then
        XCTAssertNil(context.authorizator.handledToken)
    }
    
    func test_authorize_withHandledToken_shouldBeAuthorized() {
        // Given
        let context = makeContext()
        
        context.vkApp.onSend = { _ in
            return true
        }
        
        context.webPresenterMaker.onMake = {
            Thread.sleep(forTimeInterval: 0.2)
            let presenter = WebPresenterMock()
            
            presenter.onPresesent = { _ in
                throw SessionError.cantMakeWebViewController
            }
            
            return presenter
        }
        
        context.vkApp.onHandle = { url, string in
            return ""
        }
        
        context.parser.onParse = { _ in
            return ("token", expires: 123, [:])
        }
        // When
        do {
            DispatchQueue.global().async {
                Thread.sleep(forTimeInterval: 0.1)
                context.authorizator.handle(url: URL(string: "http://examp.le")!, app: "")
            }
            
            let token = try context.authorizator.authorize(session: context.session, revoke: false)
            // Then
            XCTAssertNotNil(token)
        } catch let error {
            XCTFail("Code above should sucessful execute insted \(error)")
        }
    }
    
    func test_validate() {
        // Given
        let context = makeContext()
        // When
        let token = try? context.authorizator.validate(session: context.session, url: URL(string: "http://examp.le")!)
        // Then
        XCTAssertNil(token)
    }
}



