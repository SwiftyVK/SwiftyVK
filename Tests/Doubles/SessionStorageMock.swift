@testable import SwiftyVK

final class SessionStorageMock: SessionStorage {
    
    let `default`: Session = SessionMock()
    
    var all: [Session] {
        return [`default`]
    }
    
    func make(with config: SessionConfig) -> Session {
        return `default`
    }
    
    func destroy(session: Session) throws {}
    
    func markAsDefault(session: Session) {}
}
