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
    
    func authorize(sessionId: String, rawToken: String, expires: TimeInterval) -> Token {
        authorizeWithRawTokenCallCount += 1
        
        return TokenMock()
    }
    
    func getSavedToken(sessionId: String) -> Token? {
        return nil
    }
    
    func validate(sessionId: String, url: URL) throws -> Token {
        return TokenMock()
    }
    
    func reset(sessionId: String) -> Token? {
        return nil
    }
    
    func handle(url: URL, app: String?) {
        
    }
}
