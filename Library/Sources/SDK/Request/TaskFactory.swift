protocol TaskFactory {
    static func makeTaskFrom(
        request: Request,
        callbacks: Callbacks,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler
        ) -> Task
}

final class TaskFactoryImpl<AttemptT: Attempt, UrlRequestFactoryT: UrlRequestFactory>: TaskFactory {
    
    static func makeTaskFrom(
        request: Request,
        callbacks: Callbacks,
        taskSheduler: TaskSheduler,
        attemptSheduler: AttemptSheduler
        ) -> Task {
        let task = TaskImpl<AttemptT, UrlRequestFactoryT>(
            request: request,
            callbacks: callbacks,
            attemptSheduler: attemptSheduler
        )
        
        taskSheduler.shedule(task: task, concurrent: request.rawRequest.canSentConcurrently)
        return task
    }
}
