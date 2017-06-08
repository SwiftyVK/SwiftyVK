public protocol Session: class {
    var id: String { get }
    var config: SessionConfig { get set }
    var state: SessionState { get }
    func logIn(onSuccess: @escaping ([String : String]) -> (), onError: @escaping (Error) -> ())
    func logIn(rawToken: String, expires: TimeInterval) throws
    func logOut()
    @discardableResult
    func send(request: Request, callbacks: Callbacks) -> Task
}

protocol TaskSession {
    var token: Token? { get }
    func shedule(attempt: Attempt, concurrent: Bool) throws
}

protocol DestroyableSession: Session {
    func destroy()
}

protocol ApiErrorExecutor {
    func logIn(revoke: Bool) throws -> [String : String]
    func validate(redirectUrl: URL) throws
    func captcha(rawUrlToImage: String, dismissOnFinish: Bool) throws -> String
}

public final class SessionImpl: Session, TaskSession, DestroyableSession, ApiErrorExecutor {

    public var config: SessionConfig {
        didSet {
            updateShedulerLimit()
        }
    }
    
    public var state: SessionState {
        if id.isEmpty {
            return .destroyed
        } else if token != nil {
            return .authorized
        } else {
            return .initiated
        }
    }
    
    public var id: String
    var token: Token?

    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    private let authorizator: Authorizator
    private let taskMaker: TaskMaker
    private let captchaPresenter: CaptchaPresenter
    private let gateQueue = DispatchQueue(label: "SwiftyVK.sessionQueue")
    
    init(
        config: SessionConfig = .default,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler,
        authorizator: Authorizator,
        taskMaker: TaskMaker,
        captchaPresenter: CaptchaPresenter
        ) {
        self.id = String.random(20)
        self.config = config
        self.taskSheduler = taskSheduler
        self.attemptSheduler = attemptSheduler
        self.authorizator = authorizator
        self.taskMaker = taskMaker
        self.captchaPresenter = captchaPresenter
        
        updateShedulerLimit()
    }
    
    public func logIn(onSuccess: @escaping ([String : String]) -> (), onError: @escaping (Error) -> ()) {
         gateQueue.async {
            do {
                let info = try self.logIn(revoke: true)
                onSuccess(info)
            } catch let error {
                onError(error)
            }
        }
    }
    
    func logIn(revoke: Bool) throws -> [String : String] {
        try self.throwIfDestroyed()
        try self.throwIfAuthorized()
        
        self.token = try self.authorizator.authorize(sessionId: self.id, config: self.config, revoke: revoke)
        return self.token?.info ?? [:]
    }
    
    public func logIn(rawToken: String, expires: TimeInterval) throws {
        try gateQueue.sync {
            try throwIfDestroyed()
            try throwIfAuthorized()
            
            token = try authorizator.authorize(sessionId: id, rawToken: rawToken, expires: expires)
        }
    }
    
    public func logOut() {
        gateQueue.sync {
            token = authorizator.reset(sessionId: id)
        }
    }
    
    public func validate(redirectUrl: URL) throws {
        try gateQueue.sync {
            try throwIfDestroyed()
            token = try authorizator.validate(sessionId: id, url: redirectUrl)
        }
    }
    
    func captcha(rawUrlToImage: String) throws -> String {
        return try gateQueue.sync {
            return try captcha(rawUrlToImage: rawUrlToImage, dismissOnFinish: true)
        }
    }
    
    func captcha(rawUrlToImage: String, dismissOnFinish: Bool) throws -> String {
        try throwIfDestroyed()
        return try captchaPresenter.present(rawCaptchaUrl: rawUrlToImage, dismissOnFinish: dismissOnFinish)
    }
    
    @discardableResult
    public func send(request: Request, callbacks: Callbacks) -> Task {
        let task = taskMaker.task(
            request: request,
            callbacks: callbacks,
            session: self
        )
        
        do {
            try throwIfDestroyed()
            try shedule(task: task, concurrent: request.rawRequest.canSentConcurrently)
        } catch let error {
            callbacks.onError?(error)
        }
        
        return task
    }
    
    func shedule(task: Task, concurrent: Bool) throws {
        try gateQueue.sync {
            try throwIfDestroyed()
            try taskSheduler.shedule(task: task, concurrent: concurrent)
        }
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {
        try gateQueue.sync {
            try throwIfDestroyed()
            try attemptSheduler.shedule(attempt: attempt, concurrent: concurrent)
        }
    }
    
    private func throwIfDestroyed() throws {
        guard state > .destroyed else {
            throw SessionError.sessionDestroyed
        }
    }
    
    private func throwIfAuthorized() throws {
        guard state < .authorized else {
            throw SessionError.alreadyAuthorized
        }
    }
    
    private func updateShedulerLimit() {
        attemptSheduler.setLimit(to: config.attemptsPerSecLimit)
        
        config.onAttemptsPerSecLimitChange = { [weak attemptSheduler] newLimit in
            attemptSheduler?.setLimit(to: newLimit)
        }
    }
    
    func destroy() {
        gateQueue.sync {
            id = ""
        }
    }
    
    deinit {
        logOut()
    }
}

public func ==(lhs: Session, rhs: Session) -> Bool {
    return lhs.id == rhs.id
}
