@testable import SwiftyVK

final class AuthorizatorMock: Authorizator {
    
    var authorizeShouldThrows = false
    var authorizeCallCount = 0
    
    func authorize(session: Session, revoke: Bool) throws -> Token {
        authorizeCallCount += 1
        
        if authorizeShouldThrows {
            throw SessionError.failedAuthorization
        }
        
        return TokenMock()
    }
    
    var authorizeWithRawTokenCallCount = 0
    
    func authorize(session: Session, rawToken: String, expires: TimeInterval) -> Token {
        authorizeWithRawTokenCallCount += 1
        
        return TokenMock()
    }
    
    func validate(session: Session, url: URL) throws -> Token {
        return TokenMock()
    }
    
    func reset(session: Session) -> Token? {
        return nil
    }
    
    func handle(url: URL, app: String?) {
        
    }
}
