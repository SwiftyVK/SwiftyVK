import Foundation

/// Storage of VK user sessions
public protocol SessionsHolder: class {
    /// Default VK user session
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
    
    private unowned var sessionMaker: SessionMaker
    private let sessionsStorage: SessionsStorage
    private var sessions = NSHashTable<AnyObject>(options: .strongMemory)
    
    public var `default`: Session {
        if let realDefault = storedDefault, realDefault.state > .destroyed {
            return realDefault
        }
        
        let oldConfig = storedDefault?.config ?? .default
        sessions.remove(storedDefault)
        return makeSession(config: oldConfig, makeDefault: true)
    }
    
    private weak var storedDefault: Session?
    
    public var all: [Session] {
        return sessions.allObjects.compactMap { $0 as? Session }
    }
    
    init(
        sessionMaker: SessionMaker,
        sessionsStorage: SessionsStorage
        ) {
        self.sessionMaker = sessionMaker
        self.sessionsStorage = sessionsStorage
        
        restoreState()
    }
    
    func make() -> Session {
        return make(config: .default)
    }
    
    public func make(config: SessionConfig) -> Session {
        return makeSession(config: config)
    }
    
    @discardableResult
    private func makeSession(
        id: String = .random(20),
        config: SessionConfig = .default,
        makeDefault: Bool = false
        ) -> Session {
        
        let session = sessionMaker.session(
            id: id,
            config: config,
            sessionSaver: self
        )
        
        sessions.add(session)
        
        if makeDefault {
            storedDefault = session
        }
        
        saveState()
        return session
    }
    
    public func destroy(session: Session) throws {
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
        
        self.storedDefault = session
        saveState()
    }
    
    func saveState() {
        let encodedSessions = self.all
            .map { EncodedSession(isDefault: $0.id == storedDefault?.id, id: $0.id, config: $0.config) }
            .filter { !$0.id.isEmpty }
        
        do {
            try self.sessionsStorage.save(sessions: encodedSessions)
        }
        catch let error {
            print("Sessions not saved with error: \(error)")
        }
    }
    
    private func restoreState() {
        do {
            let restored = try sessionsStorage.restore()
            
            restored
                .filter { !$0.id.isEmpty }
                .forEach { makeSession(id: $0.id, config: $0.config, makeDefault: $0.isDefault) }
        }
        catch let error {
            print("Restore sessions failed with error: \(error)")
        }
    }
}
