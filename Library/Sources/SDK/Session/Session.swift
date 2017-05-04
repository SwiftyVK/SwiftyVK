public protocol Session: class {
    static var `default`: Session { get }
    var config: SessionConfig { get }
    
    static func new(config: SessionConfig) -> Session
    
    func send(request: Request, callbacks: Callbacks) -> Task
}

public extension Session {
    public static var `default`: Session {
        return VK.dependencyBox.defaultSession
    }
    
    public static func new(config: SessionConfig) -> Session {
        return VK.dependencyBox.session(config: config)
    }
}


public final class SessionImpl: Session {
    
    public let config: SessionConfig
    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    
    init(
        config: SessionConfig,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler
        ) {
        self.config = config
        self.taskSheduler = taskSheduler
        self.attemptSheduler = attemptSheduler
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
}
