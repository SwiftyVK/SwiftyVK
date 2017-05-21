@testable import SwiftyVK

final class AuthorizatorMock: Authorizator {
    
    func set(session: Session) {}
    
    func authorize() throws {}
    
    func authorizeWith(rawToken: String, expiresIn: Int) {}
    
    func validate(withUrl url: String) throws {}
}
