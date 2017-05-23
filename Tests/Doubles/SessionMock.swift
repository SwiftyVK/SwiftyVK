@testable import SwiftyVK

final class SessionMock: SessionInternalRepr {
    let id = String.random(20)
    var config = SessionConfig()
    var state = SessionState.initiated
    var isDefault = false
    
    func logIn() {}
    
    func logInWith(rawToken: String, expires: TimeInterval) {}
    
    func logOut() {}
    
    public func send(request: Request, callbacks: Callbacks) -> Task {
        return TaskMock()
    }
    
    func die() {
        state = .dead
    }
}
