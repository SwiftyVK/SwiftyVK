public protocol Session: class {
    static var `default`: Session { get }
    static func new() -> Session
    
    func send(request: Request, callbacks: Callbacks) -> Task
}

public final class SessionImpl: Session {
    
    private let taskSheduler: TaskSheduler
    private let attemptSheduler: AttemptSheduler
    
    init(
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler
        ) {
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

extension SessionImpl {
    public static let `default`: Session = VK.dependencyBox.defaultSession
    
    public static func new() -> Session {
        return VK.dependencyBox.session()
    }
}
