@testable import SwiftyVK
import XCTest

final class AuthorizatorMock: Authorizator {
    
    var authorizeShouldThrows = false
    var authorizeCallCount = 0
    
    var onAuthorize: ((String, SessionConfig, Bool) throws -> Token)?
    
    func authorize(sessionId: String, config: SessionConfig, revoke: Bool) throws -> Token {
        authorizeCallCount += 1
        
        guard let result = try onAuthorize?(sessionId, config, revoke) else {
            XCTFail("onAuthorize not defined")
            return TokenMock()
        }

        return result
    }
    
    var authorizeWithRawTokenCallCount = 0
    
    var onRawAuthorize: ((String, String, TimeInterval) -> Token)?
    
    func authorize(sessionId: String, rawToken: String, expires: TimeInterval) -> Token {
        authorizeWithRawTokenCallCount += 1
        
        guard let result = onRawAuthorize?(sessionId, rawToken, expires) else {
            XCTFail("onAuthorize not defined")
            return TokenMock()
        }
        
        return result
    }
    
    func getSavedToken(sessionId: String) -> Token? {
        return nil
    }
    
    var onValidate: ((String, URL) throws -> Token)?
    
    func validate(sessionId: String, url: URL) throws -> Token {
        guard let result = try onValidate?(sessionId, url) else {
            XCTFail("onAuthorize not defined")
            return TokenMock()
        }
        
        return result
    }
    
    func reset(sessionId: String) -> Token? {
        return nil
    }
    
    func handle(url: URL, app: String?) {
        
    }
}
