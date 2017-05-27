@testable import SwiftyVK

final class SessionMock: SessionInternalRepr {
    
    let id = String.random(20)
    var config = SessionConfig()
    var state = SessionState.initiated
    var isDefault = false
    
    func logIn() throws -> [String : String] {
        return [:]
    }
    
    func logInWith(rawToken: String, expires: TimeInterval) throws {}
    
    func logOut() {}
    
    @discardableResult
    func send(request: Request, callbacks: Callbacks) -> Task {
        return TaskMock()
    }
    
    func destroy() {
        state = .destroyed
    }
}
