@testable import SwiftyVK

final class AuthorizatorMock: Authorizator {
    
    var authorizeShouldThrows = false
    var authorizeCallCount = 0
    
    func authorizeWith(scopes: Scopes) throws -> Token {
        authorizeCallCount += 1
        
        if authorizeShouldThrows {
            throw SessionError.failedAuthorization
        }
        
        return TokenMock()
    }
    
    var authorizeWithRawTokenCallCount = 0
    
    func authorizeWith(rawToken: String, expires: TimeInterval) -> Token {
        authorizeWithRawTokenCallCount += 1
        
        return TokenMock()
    }
    
    func validate(withUrl url: String) throws {}
}
