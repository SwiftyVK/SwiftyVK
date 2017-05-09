public protocol Session: class {
    static var `default`: Session { get }
    var config: SessionConfig { get set }
    
    static func new() -> Session
    
    func send(request: Request, callbacks: Callbacks) -> Task
}

public extension Session {
    public static var `default`: Session {
        return VK.dependencyBox.defaultSession
    }
    
    public static func new() -> Session {
        return VK.dependencyBox.session()
    }
}


public final class SessionImpl: Session {
    
    public var config: SessionConfig {
        didSet {
            updateLimitPerSec()
        }
    }
    
    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    
    init(
        config: SessionConfig = .default,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler
        ) {
        self.config = config
        self.taskSheduler = taskSheduler
        self.attemptSheduler = attemptSheduler
        
        updateLimitPerSec()
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
