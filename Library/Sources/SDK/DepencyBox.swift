protocol DependencyBox {
    
    func sessionClass() -> Session.Type
    
    func task(
        request: Request,
        callbacks: Callbacks,
        attemptSheduler: AttemptSheduler
        ) -> Task
}

final class DependencyBoxImpl: DependencyBox {
        
    func sessionClass() -> Session.Type {
        return SessionImpl.self
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
    
    func urlRequestBuilder() -> UrlRequestBuilder {
        return UrlRequestBuilderImpl(
            queryBuilder: QueryBuilderImpl(),
            bodyBuilder: MultipartBodyBuilderImpl()
        )
    }
}
