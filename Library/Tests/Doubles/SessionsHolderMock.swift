@testable import SwiftyVK

final class SessionsHolderMock: SessionSaver, SessionsHolder {
    
    let `default`: Session = SessionMock()
    
    var all: [Session] {
        return [`default`]
    }
    
    var onMake: ((SessionConfig) -> ())?
    
    func make(config: SessionConfig) -> Session {
        onMake?(config)
        return `default`
    }
    
    var onDestroy: ((Session) throws -> ())?
    
    func destroy(session: Session) throws {
        try onDestroy?(session)
    }
    
    func markAsDefault(session: Session) {}
    
    var onSaveState: (() -> ())?
    
    func saveState() {
        onSaveState?()
    }
}
