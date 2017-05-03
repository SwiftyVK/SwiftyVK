public protocol Session: class {
    static var `default`: Session { get }
    func send(request: Request, callbacks: Callbacks) -> Task
}

public final class SessionImpl: Session {
    public static let `default`: Session = SessionImpl()
    
    let taskSheduler: TaskSheduler = TaskShedulerImpl()
    let attemptSheduler: AttemptSheduler = AttemptShedulerImpl(limit: 0)
    
//    let appId: String
//    let scopes: VK.Scope

    init() {}
    
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
