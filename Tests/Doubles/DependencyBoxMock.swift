@testable import SwiftyVK

final class DependencyBoxMock: DependencyBox {
    
    public var sessionType: Session.Type {
        return SessionMock.self
    }
    
    lazy var defaultSession: Session = {
        self.session()
    }()
    
    func session() -> Session {
        return SessionMock()
    }
    
    func attemptSheduler(limit: Int) -> AttemptSheduler {
        return AttemptShedulerMock()
    }
    
    func taskSheduler() -> TaskSheduler {
        return TaskShedulerMock()
    }
    
    func task(
        request: Request,
        callbacks: Callbacks,
        attemptSheduler: AttemptSheduler
        ) -> Task {
        
        return TaskMock()
    }
    
    private func urlRequestBuilder() -> UrlRequestBuilder {
        return UrlRequestBuilderImpl(
            queryBuilder: QueryBuilderImpl(),
            bodyBuilder: MultipartBodyBuilderImpl()
        )
    }
}
