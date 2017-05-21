public protocol Session: class {
    var config: SessionConfig { get set }
    var state: SessionState { get }
    func activate(appId: String, callbacks: SessionCallbacks) throws
    func logIn()
    func logIn(rawToken: String, expires: TimeInterval)
    func logOut()
    @discardableResult
    func send(request: Request, callbacks: Callbacks) -> Task
}

protocol SessionInternalRepr: Session {
    var id: String { get }
    var state: SessionState { get set }
}

public final class SessionImpl: SessionInternalRepr {
    
    public var config: SessionConfig {
        didSet {
            updateAttemptShedulerPerSecLimit()
        }
    }
    
    public var state: SessionState
    
    public let id: String
    private var appId: String?
    private var callbacks: SessionCallbacks = .default
    private var token: Token?
    
    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    private let taskMaker: TaskMaker
    private let authorizatorMaker: AuthorizatorMaker
    
    init(
        config: SessionConfig = .default,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler,
        authorizatorMaker: AuthorizatorMaker,
        taskMaker: TaskMaker
        ) {
        self.id = String.random(20)
        self.state = .initiated
        self.config = config
        self.taskSheduler = taskSheduler
        self.attemptSheduler = attemptSheduler
        self.taskMaker = taskMaker
        self.authorizatorMaker = authorizatorMaker
        
        updateAttemptShedulerPerSecLimit()
    }
    
    public func activate(appId: String, callbacks: SessionCallbacks) throws {
        guard state < .activated else {
            throw SessionError.alreadyActivated
        }
        
        self.state = .activated
        self.appId = appId
        self.callbacks = callbacks
    }
    
    public func logIn() {
        guard state >= .activated else {
            callbacks.onLoginFail?(SessionError.sessionIsDead)
            return
        }
        
        do {
            let token = try authorizatorMaker.authorizator().authorizeWith(scopes: callbacks.onNeedLogin())
            callbacks.onLoginSuccess?(token.info)
            self.state = .authorized
            self.token = token
        } catch let error {
            callbacks.onLoginFail?(error)
        }
    }
    
    public func logIn(rawToken: String, expires: TimeInterval) {
        guard state >= .activated else {
            callbacks.onLoginFail?(SessionError.sessionIsDead)
            return
        }
        
        let token = authorizatorMaker.authorizator().authorizeWith(rawToken: rawToken, expires: expires)
        callbacks.onLoginSuccess?(token.info)
        self.state = .authorized
        self.token = token
    }
    
    public func logOut() {
        if state == .authorized {
            state = .activated
        }
        
        self.token = nil
    }
    
    @discardableResult
    public func send(request: Request, callbacks: Callbacks) -> Task {
        
        let task = taskMaker.task(request: request, callbacks: callbacks, attemptSheduler: attemptSheduler)
        
        guard state > .dead else {
            callbacks.onError?(SessionError.sessionIsDead)
            return task
        }
        
        do {
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
    
    private func updateAttemptShedulerPerSecLimit() {
        attemptSheduler.setLimit(to: config.attemptsPerSecLimit)
        
        config.onAttemptsPerSecLimitChange = { [weak attemptSheduler] newLimit in
            attemptSheduler?.setLimit(to: newLimit)
        }
    }
}
