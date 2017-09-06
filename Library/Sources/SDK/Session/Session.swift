public protocol Session: class {
    var id: String { get }
    var config: SessionConfig { get set }
    var state: SessionState { get }
    
    func logIn(onSuccess: @escaping ([String : String]) -> (), onError: @escaping RequestCallbacks.Error)
    func logIn(rawToken: String, expires: TimeInterval) throws
    func logOut()
    @discardableResult
    func send(method: SendableMethod) -> Task
}

protocol TaskSession {
    var token: Token? { get }
    
    func shedule(attempt: Attempt, concurrent: Bool) throws
    func dismissCaptcha()
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
            sessionSaver?.saveState()
            attemptSheduler.setLimit(to: config.attemptsPerSecLimit)
        }
    }
    
    public var state: SessionState {
        if id.isEmpty {
            return .destroyed
        }
        else if token != nil {
            return .authorized
        }
        else {
            return .initiated
        }
    }
    
    public var id: String {
        didSet {
            sessionSaver?.saveState()
        }
    }
    
    var token: Token? {
        didSet {
            sendTokenChangeEvent(from: oldValue, to: token)
        }
    }

    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    private let authorizator: Authorizator
    private let taskMaker: TaskMaker
    private let captchaPresenter: CaptchaPresenter
    private weak var sessionSaver: SessionSaver?
    private weak var delegate: SwiftyVKSessionDelegate?
    private let gateQueue = DispatchQueue(label: "SwiftyVK.sessionQueue")
    
    init(
        id: String,
        config: SessionConfig,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler,
        authorizator: Authorizator,
        taskMaker: TaskMaker,
        captchaPresenter: CaptchaPresenter,
        sessionSaver: SessionSaver,
        delegate: SwiftyVKSessionDelegate?
        ) {
        self.id = id
        self.config = config
        self.taskSheduler = taskSheduler
        self.attemptSheduler = attemptSheduler
        self.authorizator = authorizator
        self.taskMaker = taskMaker
        self.captchaPresenter = captchaPresenter
        self.sessionSaver = sessionSaver
        self.delegate = delegate
        
        self.token = authorizator.getSavedToken(sessionId: id)
        sendTokenChangeEvent(from: nil, to: token)
        
        attemptSheduler.setLimit(to: config.attemptsPerSecLimit)
    }
    
    public func logIn(onSuccess: @escaping ([String : String]) -> (), onError: @escaping RequestCallbacks.Error) {
        gateQueue.async {
            do {
                let info = try self.logIn(revoke: true)
                onSuccess(info)
            }
            catch let error as VKError {
                onError(error)
            }
            catch let error {
                onError(.unknown(error))
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
            self.token = self.authorizator.reset(sessionId: self.id)
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
            try captcha(rawUrlToImage: rawUrlToImage, dismissOnFinish: true)
        }
    }
    
    func captcha(rawUrlToImage: String, dismissOnFinish: Bool) throws -> String {
        try throwIfDestroyed()
        return try captchaPresenter.present(rawCaptchaUrl: rawUrlToImage, dismissOnFinish: dismissOnFinish)
    }
    
    func dismissCaptcha() {
        captchaPresenter.dismiss()
    }
    
    @discardableResult
    public func send(method: SendableMethod) -> Task {
        let request = method.toRequest()
        request.config.inject(sessionConfig: config)

        let task = taskMaker.task(
            request: request,
            session: self
        )
    
        do {
            try throwIfDestroyed()
            try shedule(task: task, concurrent: request.canSentConcurrently)
        }
        catch let error as VKError {
            request.callbacks.onError?(error)
        }
        catch let error {
            request.callbacks.onError?(.unknown(error))
        }
        
        return task
    }
    
    func shedule(task: Task, concurrent: Bool) throws {
        try gateQueue.sync {
            try throwIfDestroyed()
            taskSheduler.shedule(task: task, concurrent: concurrent)
        }
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {
        try gateQueue.sync {
            try throwIfDestroyed()
            attemptSheduler.shedule(attempt: attempt, concurrent: concurrent)
        }
    }
    
    private func sendTokenChangeEvent(from oldToken: Token?, to newToken: Token?) {
        if oldToken != nil, let newToken = newToken {
            delegate?.vkTokenUpdated(for: id, info: newToken.info)
        }
        else if let newToken = newToken {
            delegate?.vkTokenCreated(for: id, info: newToken.info)
        }
        else if oldToken != nil {
            delegate?.vkTokenRemoved(for: id)
        }
    }
    
    private func throwIfDestroyed() throws {
        guard state > .destroyed else {
            throw VKError.sessionAlreadyDestroyed(self)
        }
    }
    
    private func throwIfAuthorized() throws {
        guard state < .authorized else {
            throw VKError.sessionAlreadyAuthorized(self)
        }
    }
    
    func destroy() {
        self.logOut()
        
        gateQueue.sync {
            self.id = ""
        }
    }
}

public func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.id == rhs.id
}
