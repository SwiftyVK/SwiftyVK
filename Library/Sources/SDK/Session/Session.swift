public protocol Session: class {
    static var `default`: Session { get }
    static func new() -> Session

    var config: SessionConfig { get set }
    var state: SessionState { get }
    func activate(appId: String, callbacks: SessionCallbacks) throws
    func send(request: Request, callbacks: Callbacks) -> Task
}

public final class SessionImpl: Session {
    
    public var config: SessionConfig {
        didSet {
            updateLimitPerSec()
        }
    }
    
    public var state: SessionState
    
    private var appId: String?
    private var callbacks: SessionCallbacks = .default
    
    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    
    init(
        config: SessionConfig = .default,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler
        ) {
        self.state = .initiated
        self.config = config
        self.taskSheduler = taskSheduler
        self.attemptSheduler = attemptSheduler
        
        updateLimitPerSec()
    }
    
    public func activate(appId: String, callbacks: SessionCallbacks) throws {
        guard state < .activated else {
            throw AuthError.alreadyActivated
        }
        
        self.state = .activated
        self.appId = appId
        self.callbacks = callbacks
    }
    
    public func send(request: Request, callbacks: Callbacks) -> Task {
        let task = VK.dependencyBox.task(
            request: request,
            callbacks: callbacks,
            attemptSheduler: attemptSheduler
        )
        
        shedule(task: task, concurrent: request.rawRequest.canSentConcurrently)
        return task
    }
    
    func shedule(task: Task, concurrent: Bool) {
        try? taskSheduler.shedule(task: task, concurrent: concurrent)
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) throws {
        try attemptSheduler.shedule(attempt: attempt, concurrent: concurrent)
    }
    
    private func updateLimitPerSec() {
        attemptSheduler.setLimit(to: config.limitPerSec)
        
        config.onLimitPerSecChange = { [weak attemptSheduler] newLimit in
            attemptSheduler?.setLimit(to: newLimit)
        }
    }
}

public extension Session {
    public static var `default`: Session {
        return VK.dependencyBox.defaultSession
    }
    
    public static func new() -> Session {
        return VK.dependencyBox.session()
    }
}
