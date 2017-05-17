public protocol Session: class {
    var config: SessionConfig { get set }
    var state: SessionState { get }
    func activate(appId: String, callbacks: SessionCallbacks) throws
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
    
    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    private let createTask: (Request, Callbacks, AttemptSheduler) -> Task
    
    init(
        config: SessionConfig = .default,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler,
        createTask: @escaping (Request, Callbacks, AttemptSheduler) -> Task
        ) {
        self.id = String.random(20)
        self.state = .initiated
        self.config = config
        self.taskSheduler = taskSheduler
        self.attemptSheduler = attemptSheduler
        self.createTask = createTask
        
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
    
    @discardableResult
    public func send(request: Request, callbacks: Callbacks) -> Task {
        
        let task = createTask(request, callbacks, attemptSheduler)
        
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
