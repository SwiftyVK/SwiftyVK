protocol TaskMaker {
    func task(request: Request, callbacks: Callbacks, attemptSheduler: AttemptSheduler) -> Task
}

protocol AttemptMaker {
    func attempt(request: URLRequest, timeout: TimeInterval, callbacks: AttemptCallbacks) -> Attempt
}

protocol TokenMaker {
    func token(token: String, expires: TimeInterval, info: [String : String]) -> Token
}

protocol DependencyBox: TaskMaker, AttemptMaker, TokenMaker {
    var sessionManager: SessionManager { get }
    func session() -> Session
    func authorizator() -> Authorizator
    func tokenRepository() -> TokenRepository
    func taskSheduler() -> TaskSheduler
    func attemptSheduler(limit: Int) -> AttemptSheduler
}

final class DependencyBoxImpl: DependencyBox {
    
    lazy public var sessionManager: SessionManager = {
        return SessionManagerImpl(dependencyBox: self)
    }()
    
    func session() -> Session {
        return SessionImpl(
            taskSheduler: taskSheduler(),
            attemptSheduler: attemptSheduler(limit: 3),
            authorizator: authorizator(),
            tokenRepository: tokenRepository(),
            taskMaker: self
        )
    }
    
    func attemptSheduler(limit: Int) -> AttemptSheduler {
        return AttemptShedulerImpl(limit: .limited(3))
    }
    
    func taskSheduler() -> TaskSheduler {
        return TaskShedulerImpl()
    }
    
    func authorizator() -> Authorizator {
        return sharedAuthorizator
    }
    
    private lazy var sharedAuthorizator: Authorizator = {
        return AuthorizatorImpl(tokenMaker: self)
    }()
    
    func task(request: Request, callbacks: Callbacks, attemptSheduler: AttemptSheduler) -> Task {
        return TaskImpl(
            request: request,
            callbacks: callbacks,
            attemptSheduler: attemptSheduler,
            urlRequestBuilder: urlRequestBuilder(),
            attemptMaker: self
        )
    }
    
    func attempt(request: URLRequest, timeout: TimeInterval, callbacks: AttemptCallbacks) -> Attempt {
        return AttemptImpl(request: request, timeout: timeout, callbacks: callbacks)
    }
    
    func tokenRepository() -> TokenRepository {
        return sharedTokenRepository
    }
    
    private lazy var sharedTokenRepository: TokenRepository = {
        return TokenRepositoryImpl()
    }()
    
    func token(token: String, expires: TimeInterval, info: [String : String]) -> Token {
        return TokenImpl(
            token: token,
            expires: expires,
            info: info
        )
    }
    
    private func urlRequestBuilder() -> UrlRequestBuilder {
        return UrlRequestBuilderImpl(
            queryBuilder: QueryBuilderImpl(),
            bodyBuilder: MultipartBodyBuilderImpl()
        )
    }
}
