#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

protocol SessionMaker {
    func session() -> Session
}

protocol TaskMaker {
    func task(request: Request, callbacks: Callbacks, attemptSheduler: AttemptSheduler) -> Task
}

protocol AttemptMaker {
    func attempt(request: URLRequest, timeout: TimeInterval, callbacks: AttemptCallbacks) -> Attempt
}

protocol TokenMaker {
    func token(token: String, expires: TimeInterval, info: [String : String]) -> Token
}

protocol DependencyBox: SessionMaker, TaskMaker, AttemptMaker, TokenMaker {
    var sessionStorage: SessionStorage { get }
    func session() -> Session
}

final class DependencyBoxImpl: DependencyBox {
    
    lazy public var sessionStorage: SessionStorage = {
        return SessionStorageImpl(sessionMaker: self)
    }()
    
    func session() -> Session {
        return SessionImpl(
            taskSheduler: TaskShedulerImpl(),
            attemptSheduler: AttemptShedulerImpl(limit: .limited(3)),
            authorizator: sharedAuthorizator,
            taskMaker: self
        )
    }
    
    private lazy var sharedAuthorizator: Authorizator = {
        
        let urlOpener: UrlOpener
        
        #if os(iOS)
            urlOpener = UIApplication.shared
        #elseif os(macOS)
            urlOpener = MacOsApplication()
        #endif
        
        return AuthorizatorImpl(
            tokenStorage: TokenStorageImpl(),
            tokenMaker: self,
            vkAppProxy: VkAppProxyImpl(urlOpener: urlOpener)
        )
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
