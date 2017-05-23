public protocol Session: class {
    var id: String { get }
    var config: SessionConfig { get set }
    var state: SessionState { get }
    func logIn() throws -> [String : String]
    func logInWith(rawToken: String, expires: TimeInterval) throws
    @discardableResult
    func send(request: Request, callbacks: Callbacks) -> Task
}

protocol SessionInternalRepr: Session {
    func die()
}

public final class SessionImpl: SessionInternalRepr {

    public var config: SessionConfig {
        didSet {
            updateShedulerLimit()
        }
    }
    
    public var state: SessionState {
        if id.isEmpty {
            return .dead
        } else if token != nil {
            return .authorized
        } else {
            return .initiated
        }
    }
    
    public var id: String
    private var token: Token?

    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    private let authorizator: Authorizator
    private let taskMaker: TaskMaker
    
    init(
        config: SessionConfig = .default,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler,
        authorizator: Authorizator,
        taskMaker: TaskMaker
        ) {
        self.id = String.random(20)
        self.config = config
        self.taskSheduler = taskSheduler
        self.attemptSheduler = attemptSheduler
        self.authorizator = authorizator
        self.taskMaker = taskMaker
        
        updateShedulerLimit()
    }
    
    public func logIn() throws -> [String : String] {
        try throwIfDead()
        token = try authorizator.authorize(session: self)
        return token?.info ?? [:]
    }
    
    public func logInWith(rawToken: String, expires: TimeInterval) throws {
        try throwIfDead()
        token = authorizator.authorize(session: self, rawToken: rawToken, expires: expires)
    }
    
    public func logOut() {
        token = authorizator.reset(session: self)
    }
    
    @discardableResult
    public func send(request: Request, callbacks: Callbacks) -> Task {
        let task = taskMaker.task(request: request, callbacks: callbacks, attemptSheduler: attemptSheduler)
        
        do {
            try throwIfDead()
            try shedule(task: task, concurrent: request.rawRequest.canSentConcurrently)
        } catch let error {
            callbacks.onError?(error)
        }
        
        return task
    }
    
    func shedule(task: Task, concurrent: Bool) throws {
        try taskSheduler.shedule(task: task, concurrent: concurrent)
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {
        try attemptSheduler.shedule(attempt: attempt, concurrent: concurrent)
    }
    
    func die() {
        id = ""
    }
    
    private func throwIfDead() throws {
        guard state > .dead else {
            throw SessionError.sessionIsDead
        }
    }
    
    private func updateShedulerLimit() {
        attemptSheduler.setLimit(to: config.attemptsPerSecLimit)
        
        config.onAttemptsPerSecLimitChange = { [weak attemptSheduler] newLimit in
            attemptSheduler?.setLimit(to: newLimit)
        }
    }
}
