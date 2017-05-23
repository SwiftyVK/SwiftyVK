public protocol Session: class {
    var id: String { get }
    var config: SessionConfig { get set }
    var state: SessionState { get }
    func logIn()
    func logInWith(rawToken: String, expires: TimeInterval)
    @discardableResult
    func send(request: Request, callbacks: Callbacks) -> Task
}

protocol SessionInternalRepr: Session {
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
        } else {
            return .initiated
        }
    }
    
    public var id: String
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
    
    public func logIn() {
        guard state > .dead else {
            VK.delegate?.vkLogInDidFail(in: self, with: SessionError.sessionIsDead)
            return
        }
        
        if let token = tokenStorage.getFor(sessionId: id) {
            self.token = token
        } else {
            logInWithAuthorizator()
        }
    }
    
    private func logInWithAuthorizator() {
        guard let scopes = VK.delegate?.vkWillLogIn(in: self) else {
            VK.delegate?.vkLogInDidFail(in: self, with: SessionError.scopesNotFound)
            return
        }
        
        do {
            let token = try authorizator.authorizeWith(scopes: scopes)
            tokenStorage.save(token: token, for:  id)
            VK.delegate?.vkLogInDidSuccess(in: self, with: token.info)
            self.token = token
        } catch let error {
            VK.delegate?.vkLogInDidFail(in: self, with: error)
        }
    }
    
    public func logInWith(rawToken: String, expires: TimeInterval) {
        guard state > .dead else {
            VK.delegate?.vkLogInDidFail(in: self, with: SessionError.sessionIsDead)
            return
        }
        
        let token = authorizator.authorizeWith(rawToken: rawToken, expires: expires)
        tokenStorage.save(token: token, for: id)
        VK.delegate?.vkLogInDidSuccess(in: self, with: token.info)
        self.token = token
    }
    
    public func logOut() {
        guard state >= .authorized else {
            return
        }

        tokenStorage.removeFor(sessionId: id)
        self.token = nil
        VK.delegate?.vkDidLogOut(in: self)
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
