protocol DependencyBox {
    
    var sessionType: Session.Type { get }
    
    var defaultSession: Session { get }
    
    func session(config: SessionConfig) -> Session
    
    func taskSheduler() -> TaskSheduler
    
    func attemptSheduler(limit: Int) -> AttemptSheduler
    
    func task(
        request: Request,
        callbacks: Callbacks,
        attemptSheduler: AttemptSheduler
        ) -> Task
}

final class DependencyBoxImpl: DependencyBox {
    
    public var sessionType: Session.Type {
        return SessionImpl.self
    }
    
    lazy var defaultSession: Session = {
        self.session(config: SessionConfig())
    }()
    
    func session(config: SessionConfig) -> Session {
        return SessionImpl(
            config: config,
            taskSheduler: taskSheduler(),
            attemptSheduler: attemptSheduler(limit: 3)
        )
    }
    
    func attemptSheduler(limit: Int) -> AttemptSheduler {
        return AttemptShedulerImpl(limit: .limit(3))
    }
    
    func taskSheduler() -> TaskSheduler {
        return TaskShedulerImpl()
    }
    
    func task(
        request: Request,
        callbacks: Callbacks,
        attemptSheduler: AttemptSheduler
        ) -> Task {
        
        return TaskImpl<AttemptImpl>(
            request: request,
            callbacks: callbacks,
            attemptSheduler: attemptSheduler,
            urlRequestBuilder: urlRequestBuilder()
        )
    }
    
    private func urlRequestBuilder() -> UrlRequestBuilder {
        return UrlRequestBuilderImpl(
            queryBuilder: QueryBuilderImpl(),
            bodyBuilder: MultipartBodyBuilderImpl()
        )
    }
}
