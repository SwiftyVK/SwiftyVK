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

protocol SessionDestroyable {
    func destroy()
}

public final class SessionImpl: Session, SessionDestroyable {

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
    private var token: Token?

    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    private let authorizator: Authorizator
    private let taskMaker: TaskMaker
    private let queue = DispatchQueue(label: "SwiftyVK.sessionQueue")
    
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
    
    public func logIn(onSuccess: @escaping ([String : String]) -> (), onError: @escaping (Error)-> ()) {
         queue.async {
            do {
                try self.throwIfDestroyed()
                try self.throwIfAuthorized()
                
                self.token = try self.authorizator.authorize(sessionId: self.id, config: self.config, revoke: true)
                onSuccess(self.token?.info ?? [:])
            } catch let error {
                onError(error)
            }
        }
    }
    
    public func logIn(rawToken: String, expires: TimeInterval) throws {
        try queue.sync {
            try throwIfDestroyed()
            try throwIfAuthorized()
            
            token = try authorizator.authorize(sessionId: id, rawToken: rawToken, expires: expires)
        }
    }
    
    public func logOut() {
        queue.sync {
            token = authorizator.reset(sessionId: id)
        }
    }
    
    @discardableResult
    public func send(request: Request, callbacks: Callbacks) -> Task {
        let task = taskMaker.task(
            request: request,
            callbacks: callbacks,
            token: token,
            attemptSheduler: attemptSheduler
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
        try queue.sync {
            try throwIfDestroyed()
            try taskSheduler.shedule(task: task, concurrent: concurrent)
        }
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {
        try queue.sync {
            try throwIfDestroyed()
            try attemptSheduler.shedule(attempt: attempt, concurrent: concurrent)
        }
    }
    
    func destroy() {
        queue.sync {
            id = ""
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
    
    deinit {
        logOut()
    }
}

public func ==(lhs: Session, rhs: Session) -> Bool {
    return lhs.id == rhs.id
}
