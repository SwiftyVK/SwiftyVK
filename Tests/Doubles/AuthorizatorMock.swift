@testable import SwiftyVK

final class AuthorizatorMock: Authorizator {
        
    func authorizeWith(scopes: Scopes) throws -> Token {
        return TokenMock()
    }
    
    func authorizeWith(rawToken: String, expires: TimeInterval) -> Token {
        return TokenMock()
    }
    
    func validate(withUrl url: String) throws {}
}
