public protocol Session: class {
    var config: SessionConfig { get set }
    var state: SessionState { get }
    func activate(appId: String, callbacks: SessionCallbacks)
    func logIn()
    func logInWith(rawToken: String, expires: TimeInterval)
    func logOut()
    @discardableResult
    func send(request: Request, callbacks: Callbacks) -> Task
}

protocol SessionInternalRepr: Session {
    var id: String { get }
    func die()
}

public final class SessionImpl: SessionInternalRepr {
    
    public var config: SessionConfig {
        didSet {
            updateAttemptShedulerPerSecLimit()
        }
    }
    
    public var state: SessionState {
        if id.isEmpty {
            return .dead
        } else if token != nil {
            return .authorized
        } else if appId != nil {
            return .activated
        } else {
            return .initiated
        }
    }
    
    public var id: String
    private var appId: String?
    private var callbacks: SessionCallbacks = .default
    private var token: Token?
    
    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    private let authorizator: Authorizator
    private let tokenStorage: TokenStorage
    private let taskMaker: TaskMaker
    
    init(
        config: SessionConfig = .default,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler,
        authorizator: Authorizator,
        tokenStorage: TokenStorage,
        taskMaker: TaskMaker
        ) {
        self.id = String.random(20)
        self.config = config
        self.taskSheduler = taskSheduler
        self.attemptSheduler = attemptSheduler
        self.authorizator = authorizator
        self.tokenStorage = tokenStorage
        self.taskMaker = taskMaker
        
        updateAttemptShedulerPerSecLimit()
    }
    
    public func activate(appId: String, callbacks: SessionCallbacks) {
        guard state < .activated else {
            return
        }
        
        self.appId = appId
        self.callbacks = callbacks
    }
    
    public func logIn() {
        guard state >= .activated else {
            callbacks.onLoginFail?(SessionError.sessionIsDead)
            return
        }
        
        if let token = tokenStorage.getFor(sessionId: id) {
            self.token = token
        } else {
            logInWithAuthorizator()
        }
    }
    
    private func logInWithAuthorizator() {
        do {
            let token = try authorizator.authorizeWith(scopes: callbacks.onNeedLogin())
            tokenStorage.save(token: token, for:  id)
            callbacks.onLoginSuccess?(token.info)
            self.token = token
        } catch let error {
            callbacks.onLoginFail?(error)
        }
    }
    
    public func logInWith(rawToken: String, expires: TimeInterval) {
        guard state >= .activated else {
            callbacks.onLoginFail?(SessionError.sessionIsDead)
            return
        }
        
        let token = authorizator.authorizeWith(rawToken: rawToken, expires: expires)
        tokenStorage.save(token: token, for: id)
        callbacks.onLoginSuccess?(token.info)
        self.token = token
    }
    
    public func logOut() {
        guard state >= .authorized else {
            return
        }

        tokenStorage.removeFor(sessionId: id)
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
    
    func die() {
        id = ""
    }
    
    private func updateAttemptShedulerPerSecLimit() {
        attemptSheduler.setLimit(to: config.attemptsPerSecLimit)
        
        config.onAttemptsPerSecLimitChange = { [weak attemptSheduler] newLimit in
            attemptSheduler?.setLimit(to: newLimit)
        }
    }
}
