import Foundation

public protocol SessionsHolder: class {
    var `default`: Session { get }
    var all: [Session] { get }
    func make(config: SessionConfig) -> Session
    func destroy(session: Session) throws
    func markAsDefault(session: Session) throws
}

protocol SessionSaver: class {
    func saveState()
}

extension SessionsHolder {
    
    func make() -> Session {
        return make(config: .default)
    }
}

public final class SessionsHolderImpl: SessionsHolder, SessionSaver {
    
    private let sessionMaker: SessionMaker
    private let sessionsStorage: SessionsStorage
    private var sessions = NSHashTable<AnyObject>(options: .strongMemory)
    private var canKillDefaultSessions = false
    
    lazy public var `default`: Session = {
        return self.make()
    }()
    
    public var all: [Session] {
        return sessions.allObjects.flatMap { $0 as? Session }
    }
    
    init(
        sessionMaker: SessionMaker,
        sessionsStorage: SessionsStorage
        ) {
        self.sessionMaker = sessionMaker
        self.sessionsStorage = sessionsStorage
        
        restoreState()
    }
    
    public func make(config: SessionConfig) -> Session {
        let session = sessionMaker.session(id: .random(20), config: config, sessionSaver: self)
        
        sessions.add(session)
        saveState()
        return session
    }
    
    public func destroy(session: Session) throws {
        if !canKillDefaultSessions && session == `default` {
            throw SessionError.cantDestroyDefaultSession
        }
        
        if session.state == .destroyed {
            throw SessionError.sessionDestroyed
        }
        
        (session as? DestroyableSession)?.destroy()
        sessions.remove(session)
    }
    
    public func markAsDefault(session: Session) throws {
        if session.state == .destroyed {
            throw SessionError.sessionDestroyed
        }
        
        self.default = session
    }

    func saveState() {
        DispatchQueue.global().async {
            let encodedSessions = self.all.map {
                EncodedSession(isDefault: $0 == self.default, id: $0.id, config: $0.config)
            }
            
            do {
                try self.sessionsStorage.save(sessions: encodedSessions)
            } catch let error {
                print("Sessions not saved with error: \(error)")
            }
        }
    }
    
    private func restoreState() {
        do {
            let decodedSessions = try sessionsStorage.restore()
                .filter { !$0.id.isEmpty }
            
            decodedSessions
                .filter { !$0.isDefault }
                .map { sessionMaker.session(id: $0.id, config: $0.config, sessionSaver: self) }
                .forEach { sessions.add($0) }
            
            if let defaultSession = decodedSessions
                .first(where: { $0.isDefault })
                .map({ sessionMaker.session(id: $0.id, config: $0.config, sessionSaver: self) }) {
                sessions.add(defaultSession)
                `default` = defaultSession
            }
            
            
        } catch let error {
            print("Restore sessions failed with error: \(error)")
        }
    }
    
    deinit {
        canKillDefaultSessions = true
        sessions.allObjects.flatMap { $0 as? Session } .forEach { try? destroy(session: $0) }
    }
}
