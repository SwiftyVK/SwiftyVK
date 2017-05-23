import Foundation

public protocol SessionStorage: class {
    var `default`: Session { get }
    var all: [Session] { get }
    func new(with config: SessionConfig) -> Session
    func kill(session: Session) throws
    func makeDefault(session: Session) throws
}

extension SessionStorage {
    
    func new() -> Session {
        return new(with: .default)
    }
}

public final class SessionStorageImpl: SessionStorage {

    private let sessionMaker: SessionMaker
    private var sessions = NSHashTable<AnyObject>(options: .strongMemory)
    private var canKillDefaultSessions = false
    
    lazy public var `default`: Session = {
        return self.new()
    }()
    
    public var all: [Session] {
        return sessions.allObjects
            .flatMap { $0 as? Session }
            .filter { $0.state > .dead }
    }
    
    init(sessionMaker: SessionMaker) {
        self.sessionMaker = sessionMaker
    }
    
    public func new(with config: SessionConfig) -> Session {
        let session = sessionMaker.session()
        session.config = config

        sessions.add(session)
        return session
    }
    
    public func kill(session: Session) throws {
        if !canKillDefaultSessions && session === `default` {
            throw SessionError.cantKillDefaultSession
        }
        
        if session.state == .dead {
            throw SessionError.sessionIsDead
        }
        
        (session as? SessionInternalRepr)?.die()
        sessions.remove(session)
    }
    
    public func makeDefault(session: Session) throws {
        if session.state == .dead {
            throw SessionError.sessionIsDead
        }
        
        self.default = session
    }
    
    deinit {
        canKillDefaultSessions = true
        sessions.allObjects
            .flatMap { $0 as? Session }
            .filter { $0.state > .dead }
            .forEach { try? kill(session: $0) }
    }
}
