@testable import SwiftyVK

final class SessionManagerMock: SessionManager {
    
    let `default`: Session = SessionMock()
    
    func new(config: SessionConfig) -> Session {
        return `default`
    }
    
    func kill(session: Session) throws {}
    
    func makeDefault(session: Session) {}
}
