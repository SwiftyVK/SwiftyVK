import XCTest
@testable import SwiftyVK

final class AuthorizatorTests: XCTestCase {
    
    func makeContext() -> (
        authorizator: AuthorizatorImpl,
        delegate: SwiftyVKDelegateMock,
        storage: TokenStorageMock,
        tokenMaker: TokenMakerMock,
        parser: TokenParserMock,
        vkApp: VKAppProxyMock,
        webPresenter: WebPresenterMock,
        sessionId: String,
        sessionConfig: SessionConfig
        ) {
            let delegate = SwiftyVKDelegateMock()
            let storage = TokenStorageMock()
            let tokenMaker = TokenMakerMock()
            let parser = TokenParserMock()
            let vkApp = VKAppProxyMock()
            let webPresenter = WebPresenterMock()
            let session = SessionMock()
            let cookiesHolder = CookiesHolderMock()
            
            let authorizator = AuthorizatorImpl(
                appId: "1234567890",
                delegate: delegate,
                tokenStorage: storage,
                tokenMaker: tokenMaker,
                tokenParser: parser,
                vkAppProxy: vkApp,
                webPresenter: webPresenter,
                cookiesHolder: cookiesHolder
            )
            
            return (
                authorizator,
                delegate,
                storage,
                tokenMaker,
                parser,
                vkApp,
                webPresenter,
                session.id,
                session.config
            )
    }
    
    
    func test_getSavedToken_whenTokenInStorage() {
        // Given
        let context = makeContext()
        
        context.storage.onGet = { sessionId in
            XCTAssertEqual(sessionId, "TEST")
            return TokenMock()
        }
        
        // When
        let token = context.authorizator.getSavedToken(sessionId: "TEST")
        // Then
        XCTAssertNotNil(token)
    }
    
    func test_authorize_errorOnParseToken() {
        // Given
        let context = makeContext()
        // When
        do {
            _ = try context.authorizator.authorize(
                sessionId: context.sessionId,
                config: context.sessionConfig,
                revoke: false
            )
            // Then
            XCTFail("Code above should throw error")
        } catch let error {
            XCTAssertEqual(error.asVK, VKError.cantParseTokenInfo(""))
        }
    }
    
    func test_authorize_withSucessfullCreatedToken() {
        // Given
        let context = makeContext()
        
        context.tokenMaker.onMake = { _, _, _ in
            return TokenMock()
        }
        
        context.parser.onParse = { _ in
            return ("token", expires: 123, [:])
        }
        // When
        let token = try? context.authorizator.authorize(
            sessionId: context.sessionId,
            config: context.sessionConfig,
            revoke: false
        )
        // Then
        XCTAssertNotNil(token)
    }
    
    func test_authorize_withDelegateWillLoginCallCount() {
        // Given
        let context = makeContext()
        var delegateCallCount = 0
        
        context.delegate.onVKNeedsScopes = { _ in
            delegateCallCount += 1
            return []
        }
        
        // When
        _ = try? context.authorizator.authorize(
            sessionId: context.sessionId,
            config: context.sessionConfig,
            revoke: true
        )
        // Then
        XCTAssertEqual(delegateCallCount, 1)
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
        _ = try? context.authorizator.authorize(
            sessionId: context.sessionId,
            rawToken: "1234567890",
            expires: 123
        )
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
            XCTAssertEqual(context.sessionId, sessionId)
            
            saveCallCount += 1
        }
        // When
        _ = try? context.authorizator.authorize(
            sessionId: context.sessionId,
            rawToken: "1234567890",
            expires: 123
        )
        // Then
        XCTAssertEqual(saveCallCount, 1)
    }
    
    func test_reset_returnedTokenShouldBeNil() {
        // Given
        let context = makeContext()
        // When
        let token = context.authorizator.reset(sessionId: context.sessionId)
        // Then
        XCTAssertNil(token)
    }
    
    func test_reset_storageShouldRemoveOnce() {
        // Given
        let context = makeContext()
        var removeCallCount = 0
        
        context.storage.onRemove = { sessionId in
            XCTAssertEqual(context.sessionId, sessionId)
            removeCallCount += 1
        }
        // When
        _ = context.authorizator.reset(sessionId: context.sessionId)
        // Then
        XCTAssertEqual(removeCallCount, 1)
    }
    
    func test_handle_withNilResponse_shouldCantHandle() {
        // Given
        let context = makeContext()
        
        context.tokenMaker.onMake = { _, _, _ in
            return TokenMock()
        }
        
        context.vkApp.onHandle = { url, string in
            return nil
        }
        // When
        context.authorizator.handle(url: URL(string: "http://examp.le")!, app: "")
        // Then
        XCTAssertNil(context.authorizator.vkAppToken)
    }
    
    func test_authorize_withHandledToken_shouldBeAuthorized() {
        // Given
        let context = makeContext()
        let exp = expectation(description: "")
        
        context.tokenMaker.onMake = { _, _, _ in
            return TokenMock()
        }
        
        context.vkApp.onSend = { _ in
            return true
        }
        
        context.webPresenter.onPresesent = { _ in
            Thread.sleep(forTimeInterval: 0.2)
            throw VKError.unexpectedResponse
        }
        
        context.vkApp.onHandle = { url, string in
            return ""
        }
        
        context.parser.onParse = { _ in
            return ("token", expires: 123, [:])
        }
        // When
        DispatchQueue.global().async {
            do {
                Thread.sleep(forTimeInterval: 0.1)
                context.authorizator.handle(url: URL(string: "http://examp.le")!, app: "")
                
                let token = try context.authorizator.authorize(
                    sessionId: context.sessionId,
                    config: context.sessionConfig,
                    revoke: false
                )
                // Then
                XCTAssertNotNil(token)
            } catch let error {
                XCTFail("Code above should sucessful execute insted \(error)")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func test_validate() {
        // Given
        let context = makeContext()
        // When
        let token = try? context.authorizator.validate(
            sessionId: context.sessionId, url: URL(string: "http://examp.le")!
        )
        // Then
        XCTAssertNil(token)
    }
}



