@testable import SwiftyVK
import XCTest

final class AuthorizatorMock: Authorizator {
    
    var authorizeShouldThrows = false
    var authorizeCallCount = 0
    
    var onAuthorize: ((String, SessionConfig, Bool) throws -> InvalidatableToken)?
    
    func authorize(sessionId: String, config: SessionConfig, revoke: Bool) throws -> InvalidatableToken {
        authorizeCallCount += 1
        
        guard let result = try onAuthorize?(sessionId, config, revoke) else {
            XCTFail("onAuthorize not defined")
            return TokenMock()
        }

        return result
    }
    
    var authorizeWithRawTokenCallCount = 0
    
    var onRawAuthorize: ((String, String, TimeInterval) -> InvalidatableToken)?
    
    func authorize(sessionId: String, rawToken: String, expires: TimeInterval) -> InvalidatableToken {
        authorizeWithRawTokenCallCount += 1
        
        guard let result = onRawAuthorize?(sessionId, rawToken, expires) else {
            XCTFail("onAuthorize not defined")
            return TokenMock()
        }
        
        return result
    }
    
    var onGetSavedToken: ((String) -> InvalidatableToken)?
    
    func getSavedToken(sessionId: String) -> InvalidatableToken? {
        return onGetSavedToken?(sessionId)
    }
    
    var onValidate: ((String, URL) throws -> InvalidatableToken)?
    
    func validate(sessionId: String, url: URL) throws -> InvalidatableToken {
        guard let result = try onValidate?(sessionId, url) else {
            XCTFail("onAuthorize not defined")
            return TokenMock()
        }
        
        return result
    }
    
    func reset(sessionId: String) -> InvalidatableToken? {
        return nil
    }
    
    func handle(url: URL, app: String?) {
        
    }
}
