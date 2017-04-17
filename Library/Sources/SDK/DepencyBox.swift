protocol DepencyBox {
    
    func sessionClass() -> Session.Type

    func task(
        request: Request,
        callbacks: Callbacks,
        attemptSheduler: AttemptSheduler
        ) -> Task
}

final class DepencyBoxImpl: DepencyBox {
    
    init() {}
    
    func sessionClass() -> Session.Type {
        return SessionImpl.self
    }
    
    func task(
        request: Request,
        callbacks: Callbacks,
        attemptSheduler: AttemptSheduler
        ) -> Task {
        
        return TaskImpl<AttemptImpl, UrlRequestFactoryImpl>(
            request: request,
            callbacks: callbacks,
            attemptSheduler: attemptSheduler
        )
    }
}
