@testable import SwiftyVK

final class SessionsHolderMock: SessionsHolder {
    
    let `default`: Session = SessionMock()
    
    var all: [Session] {
        return [`default`]
    }
    
    func make(config: SessionConfig) -> Session {
        return `default`
    }
    
    func destroy(session: Session) throws {}
    
    func markAsDefault(session: Session) {}
}
