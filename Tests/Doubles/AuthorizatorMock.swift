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
    
    func validate(with url: URL) throws {}
    
    func reset(session: Session) -> Token? {
        return nil
    }
}
