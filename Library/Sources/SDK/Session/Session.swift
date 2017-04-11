public protocol Session: class {
    static var `default`: Session { get }
}

protocol InternalSession: Session {
    func shedule(task: Task, concurrent: Bool)
    func shedule(attempt: Attempt, concurrent: Bool)
}

public final class SessionImpl: InternalSession {
    public static let `default`: Session = SessionImpl()
    
    let taskSheduler: TaskSheduler = TaskShedulerImpl()
    let attemptSheduler: AttemptSheduler = AttemptShedulerImpl(limit: 0)
    
//    let appId: String
//    let scopes: VK.Scope
    
    init() {}
    
    func shedule(task: Task, concurrent: Bool) {
        taskSheduler.shedule(task: task, concurrent: concurrent)
    }
    
    func shedule(attempt: Attempt, concurrent: Bool) {
        attemptSheduler.shedule(attempt: attempt, concurrent: concurrent)
    }
}
