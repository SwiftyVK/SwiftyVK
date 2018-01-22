import Foundation

/// VK user session
public protocol Session: class {
    /// Internal SwiftyVK session identifier
    var id: String { get }
    /// Current session configuration.
    /// All requests in session inherit it
    var config: SessionConfig { get set }
    /// Current session state
    var state: SessionState { get }
    /// Long poll client for this session
    var longPoll: LongPoll { get }
    
    /// Log in user with oAuth or VK app
    /// - parameter onSuccess: clousure which will be executed when user sucessfully logged.
    /// Returns info about logged user.
    /// - parameter onError: clousure which will be executed when logging failed.
    /// Returns cause of failure.
    func logIn(onSuccess: @escaping ([String: String]) -> (), onError: @escaping RequestCallbacks.Error)
    /// Log in user with raw token
    /// - parameter rawToken: token raw string
    /// - parameter expires: token expires time from now. Zero is infinite token.
    func logIn(rawToken: String, expires: TimeInterval) throws
    /// Log out user, remove all data and destroy current session
    func logOut()
    /// Send request in this session
    /// - parameter method: VK API method
    @discardableResult
    func send(method: SendableMethod) -> Task
    
    /// Show share dialog
    @available(iOS 8.0, macOS 10.11, *)
    func share(
        _ context: ShareContext,
        onSuccess: @escaping RequestCallbacks.Success,
        onError: @escaping RequestCallbacks.Error
    )
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
    func logIn(revoke: Bool) throws -> [String: String]
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
        else if token?.isValid == true {
            return .authorized
        }
        else {
            return .initiated
        }
    }
    
    public lazy var longPoll: LongPoll = {
        longPollMaker.longPoll(session: self)
    }()
    
    public internal(set) var id: String
    
    private(set) var token: Token? {
        didSet {
            sendTokenChangeEvent(from: oldValue, to: token)
        }
    }

    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    private let authorizator: Authorizator
    private unowned var taskMaker: TaskMaker
    private unowned var longPollMaker: LongPollMaker
    private let captchaPresenter: CaptchaPresenter
    private weak var sharePresenterMaker: SharePresenterMaker?
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
        sharePresenterMaker: SharePresenterMaker,
        sessionSaver: SessionSaver,
        longPollMaker: LongPollMaker,
        delegate: SwiftyVKSessionDelegate?
        ) {
        self.id = id
        self.config = config
        self.taskSheduler = taskSheduler
        self.attemptSheduler = attemptSheduler
        self.authorizator = authorizator
        self.taskMaker = taskMaker
        self.longPollMaker = longPollMaker
        self.captchaPresenter = captchaPresenter
        self.sharePresenterMaker = sharePresenterMaker
        self.sessionSaver = sessionSaver
        self.delegate = delegate
        
        self.token = authorizator.getSavedToken(sessionId: id)
        sendTokenChangeEvent(from: nil, to: token)
        
        attemptSheduler.setLimit(to: config.attemptsPerSecLimit)
    }
    
    public func logIn(onSuccess: @escaping ([String: String]) -> (), onError: @escaping RequestCallbacks.Error) {
        gateQueue.async {
            do {
                let info = try self.logIn(revoke: true)
                DispatchQueue.global().async {
                    onSuccess(info)
                }
            }
            catch let error {
                DispatchQueue.global().async {
                    onError(error.toVK())
                }
            }
        }
    }
   
    @discardableResult
    func logIn(revoke: Bool) throws -> [String: String] {
        try throwIfDestroyed()
        try throwIfAuthorized()
        
        let token = try authorizator.authorize(
            sessionId: id,
            config: config,
            revoke: revoke
        )
        
        self.token = token
        
        return token.info
    }
    
    public func logIn(rawToken: String, expires: TimeInterval) throws {
        try gateQueue.sync {
            try throwIfDestroyed()
            try throwIfAuthorized()
            token = try authorizator.authorize(sessionId: id, rawToken: rawToken, expires: expires)
        }
    }
    
    public func logOut() {
        unsafeDestroy()
    }
    
    public func validate(redirectUrl: URL) throws {
        try gateQueue.sync {
            try throwIfDestroyed()
            try throwIfNotAuthorized()
            token = try authorizator.validate(sessionId: id, url: redirectUrl)
        }
    }
    
    func captcha(rawUrlToImage: String) throws -> String {
        return try gateQueue.sync {
            try throwIfDestroyed()
            try throwIfNotAuthorized()
            return try captcha(rawUrlToImage: rawUrlToImage, dismissOnFinish: true)
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
            try shedule(task: task)
        }
        catch let error {
            request.callbacks.onError?(error.toVK())
        }
        
        return task
    }
    
    public func share(
        _ context: ShareContext,
        onSuccess: @escaping RequestCallbacks.Success,
        onError: @escaping RequestCallbacks.Error
        ) {
        
        do {
            try throwIfDestroyed()
        }
        catch let error {
            onError(error.toVK())
        }
        
        if state >= .authorized {
            forceShare(context, onSuccess: onSuccess, onError: onError)
        }
        else {
            logIn(
                onSuccess: { [weak self] _ in
                    self?.forceShare(context, onSuccess: onSuccess, onError: onError)
                },
                onError: { onError($0) }
            )
        }
    }
    
    public func forceShare(
        _ context: ShareContext,
        onSuccess: @escaping RequestCallbacks.Success,
        onError: @escaping RequestCallbacks.Error
        ) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            do {
                guard let strongSelf = self else { return }
                guard let presenter = strongSelf.sharePresenterMaker?.sharePresenter() else { return }
                let data = try presenter.share(context, in: strongSelf)
                try onSuccess(data)
            }
            catch {
                onError(error.toVK())
            }
        }
    }
    
    func shedule(task: Task) throws {
        try gateQueue.sync {
            try throwIfDestroyed()
            taskSheduler.shedule(task: task)
        }
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {
        try gateQueue.sync {
            try throwIfDestroyed()
            
            if token?.isValid == false {
                try logIn(revoke: false)
            }
            
            attemptSheduler.shedule(attempt: attempt, concurrent: concurrent)
        }
    }
    
    private func sendTokenChangeEvent(from oldToken: Token?, to newToken: Token?) {
    
        DispatchQueue.global().async { [id] in
            if oldToken != nil, let newToken = newToken {
                self.delegate?.vkTokenUpdated(for: id, info: newToken.info)
            }
            else if let newToken = newToken {
                self.delegate?.vkTokenCreated(for: id, info: newToken.info)
            }
            else if oldToken != nil {
                self.delegate?.vkTokenRemoved(for: id)
            }
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
    
    private func throwIfNotAuthorized() throws {
        guard state >= .authorized else {
            throw VKError.sessionIsNotAuthorized(self)
        }
    }
    
    func destroy() {
        gateQueue.sync { unsafeDestroy() }
    }
    
    private func unsafeDestroy() {
        self.token = self.authorizator.reset(sessionId: self.id)
        self.id = ""
        self.sessionSaver?.saveState()
    }
}

public func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.id == rhs.id
}
