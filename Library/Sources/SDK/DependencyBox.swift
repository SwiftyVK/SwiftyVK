protocol TaskMaker {
    func task(request: Request, callbacks: Callbacks, attemptSheduler: AttemptSheduler) -> Task
}

protocol AuthorizatorMaker {
    func authorizator() -> Authorizator
}

protocol TokenMaker {
    func token(token: String, expires: TimeInterval, info: [String : String]) -> Token
}

protocol DependencyBox: TaskMaker, AuthorizatorMaker, TokenMaker {
    var sessionManager: SessionManager { get }
    func session() -> Session
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
            tokenRepository: tokenRepository(),
            dependencyMaker: self
        )
    }
    
    func attemptSheduler(limit: Int) -> AttemptSheduler {
        return AttemptShedulerImpl(limit: .limited(3))
    }
    
    func taskSheduler() -> TaskSheduler {
        return TaskShedulerImpl()
    }
    
    func authorizator() -> Authorizator {
        return AuthorizatorImpl(tokenMaker: self)
    }
    
    func task(request: Request, callbacks: Callbacks, attemptSheduler: AttemptSheduler) -> Task {
        return TaskImpl<AttemptImpl>(
            request: request,
            callbacks: callbacks,
            attemptSheduler: attemptSheduler,
            urlRequestBuilder: urlRequestBuilder()
        )
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
