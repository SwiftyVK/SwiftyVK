@testable import SwiftyVK

final class SessionManagerMock: SessionManager {
    
    let `default`: Session = SessionMock()
    
    var all: [Session] {
        return [`default`]
    }
    
    func new(with config: SessionConfig) -> Session {
        return `default`
    }
    
    func kill(session: Session) throws {}
    
    func makeDefault(session: Session) {}
}
