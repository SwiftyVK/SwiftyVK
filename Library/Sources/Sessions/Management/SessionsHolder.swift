import Foundation

public protocol SessionsHolder: class {
    var `default`: Session { get }
    
    // For now SwiftyVK does not support multisession
    // Probably, in the future it will be done
    // If you want to use more than one session, let me know about it
    // Maybe, you make PR to SwiftyVK ;)
    //    func make(config: SessionConfig) -> Session
    //    var all: [Session] { get }
    //    func destroy(session: Session) throws
    //    func markAsDefault(session: Session) throws
}

protocol SessionSaver: class {
    func saveState()
}

public final class SessionsHolderImpl: SessionsHolder, SessionSaver {
    
    private let sessionMaker: SessionMaker
    private let sessionsStorage: SessionsStorage
    private var sessions = NSHashTable<AnyObject>(options: .strongMemory)
    private var canKillDefaultSessions = false
    
    lazy public var `default`: Session = {
        self.sessionMaker.session(id: .random(20), config: .default, sessionSaver: self)
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
        self.sessions.add(`default`)
        saveState()
    }
    
    func make() -> Session {
        return make(config: .default)
    }
    
    public func make(config: SessionConfig) -> Session {
        let session = sessionMaker.session(id: .random(20), config: config, sessionSaver: self)
        
        sessions.add(session)
        saveState()
        return session
    }
    
    public func destroy(session: Session) throws {
        if !canKillDefaultSessions && session == `default` {
            throw VKError.cantDestroyDefaultSession
        }
        
        if session.state == .destroyed {
            throw VKError.sessionAlreadyDestroyed(session)
        }
        
        (session as? DestroyableSession)?.destroy()
        sessions.remove(session)
    }
    
    public func markAsDefault(session: Session) throws {
        if session.state == .destroyed {
            throw VKError.sessionAlreadyDestroyed(session)
        }
        
        self.default = session
    }
    
    func saveState() {
        let encodedSessions = self.all.map {
            EncodedSession(isDefault: $0 == self.`default`, id: $0.id, config: $0.config)
        }
        
        do {
            try self.sessionsStorage.save(sessions: encodedSessions)
        }
        catch let error {
            print("Sessions not saved with error: \(error)")
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
            
        }
        catch let error {
            print("Restore sessions failed with error: \(error)")
        }
    }
}
