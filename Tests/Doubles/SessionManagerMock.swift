@testable import SwiftyVK

final class SessionManagerMock: SessionManager {
    
    let `default`: Session = SessionMock()
    
    func all() -> [Session] {
        return [`default`]
    }
    
    func new(config: SessionConfig) -> Session {
        return `default`
    }
    
    func kill(session: Session) throws {}
    
    func makeDefault(session: Session) {}
}
