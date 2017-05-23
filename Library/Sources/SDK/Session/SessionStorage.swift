import Foundation

public protocol SessionStorage: class {
    var `default`: Session { get }
    var all: [Session] { get }
    func make(with config: SessionConfig) -> Session
    func destroy(session: Session) throws
    func markAsDefault(session: Session) throws
}

extension SessionStorage {
    
    func make() -> Session {
        return make(with: .default)
    }
}

public final class SessionStorageImpl: SessionStorage {

    private let sessionMaker: SessionMaker
    private var sessions = NSHashTable<AnyObject>(options: .strongMemory)
    private var canKillDefaultSessions = false
    
    lazy public var `default`: Session = {
        return self.make()
    }()
    
    public var all: [Session] {
        return sessions.allObjects
            .flatMap { $0 as? Session }
            .filter { $0.state > .destroyed }
    }
    
    init(sessionMaker: SessionMaker) {
        self.sessionMaker = sessionMaker
    }
    
    public func make(with config: SessionConfig) -> Session {
        let session = sessionMaker.session()
        session.config = config

        sessions.add(session)
        return session
    }
    
    public func destroy(session: Session) throws {
        if !canKillDefaultSessions && session === `default` {
            throw SessionError.cantDestroyDefaultSession
        }
        
        if session.state == .destroyed {
            throw SessionError.sessionDestroyed
        }
        
        (session as? SessionInternalRepr)?.die()
        sessions.remove(session)
    }
    
    public func markAsDefault(session: Session) throws {
        if session.state == .destroyed {
            throw SessionError.sessionDestroyed
        }
        
        self.default = session
    }
    
    deinit {
        canKillDefaultSessions = true
        sessions.allObjects
            .flatMap { $0 as? Session }
            .filter { $0.state > .destroyed }
            .forEach { try? destroy(session: $0) }
    }
}
