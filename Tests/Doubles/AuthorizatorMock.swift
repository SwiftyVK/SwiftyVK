@testable import SwiftyVK

final class AuthorizatorMock: Authorizator {
    
    var authorizeShouldThrows = false
    var authorizeCallCount = 0
    
    func authorize(sessionId: String, config: SessionConfig, revoke: Bool) throws -> Token {
        authorizeCallCount += 1
        
        if authorizeShouldThrows {
            throw LegacySessionError.failedAuthorization
        }
        
        return TokenMock()
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
