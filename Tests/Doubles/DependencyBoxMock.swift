@testable import SwiftyVK

final class DependencyBoxMock: DependencyBox {
    
    var sessionStorage: SessionStorage {
        return SessionStorageMock()
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
    
    func attempt(request: URLRequest, timeout: TimeInterval, callbacks: AttemptCallbacks) -> Attempt {
        return AttemptMock()
    }
    
    func authorizator() -> Authorizator {
        return AuthorizatorMock()
    }
    
    func tokenStorage() -> TokenStorage {
        return TokenStorageMock()
    }
    
    func token(token: String, expires: TimeInterval, info: [String : String]) -> Token {
        return TokenMock()
    }
    
    private func urlRequestBuilder() -> UrlRequestBuilder {
        return UrlRequestBuilderImpl(
            queryBuilder: QueryBuilderImpl(),
            bodyBuilder: MultipartBodyBuilderImpl()
        )
    }
}
