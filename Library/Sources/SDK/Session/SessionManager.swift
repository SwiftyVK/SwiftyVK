import Foundation

public protocol SessionManager: class {
    var `default`: Session { get }
    func new(config: SessionConfig) -> Session
    func kill(session: Session) throws
    func makeDefault(session: Session)
}

extension SessionManager {
    
    func new() -> Session {
        return new(config: .default)
    }
}

public class SessionManagerImpl: SessionManager {

    private let dependencyBox: DependencyBox
    
    private var sessions = NSHashTable<AnyObject>(options: .strongMemory)
    lazy public var `default`: Session = { return self.new() }()
    
    init(dependencyBox: DependencyBox) {
        self.dependencyBox = dependencyBox
    }
    
    public func new(
        config: SessionConfig
        ) -> Session {
        
        let session = dependencyBox.session()
        session.config = config

        sessions.add(session)
        return session
    }
    
    public func kill(session: Session) throws {
        
        guard session !== `default` else {
            throw SessionError.cantKillDefaultSession
        }
        
        sessions.remove(session)
    }
    
    public func makeDefault(session: Session) {
        self.default = session
    }
}
