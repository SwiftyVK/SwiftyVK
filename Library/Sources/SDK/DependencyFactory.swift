#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

protocol DependencyFactory:
    DependencyHolder,
    SessionMaker,
    TaskMaker,
    AttemptMaker,
    TokenMaker,
    WebPresenterMaker,
    CaptchaPresenterMaker
{}

protocol DependencyHolder: SessionStorageHolder, AuthorizatorHolder {
    init(appId: String, delegate: SwiftyVKDelegate?)
}

protocol SessionStorageHolder {
    var sessionStorage: SessionStorage { get }
}

protocol AuthorizatorHolder {
    var authorizator: Authorizator { get }
}

protocol SessionMaker {
    func session() -> Session
}

protocol TaskMaker {
    func task(request: Request, callbacks: Callbacks, session: TaskSession) -> Task
}

protocol AttemptMaker {
    func attempt(request: URLRequest, timeout: TimeInterval, callbacks: AttemptCallbacks) -> Attempt
}

protocol TokenMaker {
    func token(token: String, expires: TimeInterval, info: [String : String]) -> Token
}

protocol WebPresenterMaker {
    func webPresenter() -> WebPresenter?
}

protocol CaptchaPresenterMaker {
    func captchaPresenter() -> CaptchaPresenter?
}

final class DependencyFactoryImpl: DependencyFactory {
    
    private let appId: String
    private weak var delegate: SwiftyVKDelegate?
    private let uiSyncQueue = DispatchQueue(label: "SwiftyVK.uiSyncQueue")
    
    init(appId: String, delegate: SwiftyVKDelegate?) {
        self.appId = appId
        self.delegate = delegate
    }
    
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
    
    var authorizator: Authorizator {
        return sharedAuthorizator
    }
    
    private lazy var sharedAuthorizator: Authorizator = {
        
        let urlOpener: UrlOpener
        
        #if os(iOS)
            urlOpener = UIApplication.shared
        #elseif os(macOS)
            urlOpener = UrlOpener_macOS()
        #endif
        
        let vkAppProxy = VkAppProxyImpl(
            appId: self.appId,
            urlOpener: urlOpener
        )
        
        return AuthorizatorImpl(
            appId: self.appId,
            delegate: self.delegate,
            tokenStorage: TokenStorageImpl(),
            tokenMaker: self,
            tokenParser: TokenParserImpl(),
            vkAppProxy: vkAppProxy,
            webPresenterMaker: self
        )
    }()
    
    func webPresenter() -> WebPresenter? {
        
        #if os(iOS)
            let webController = WebController_iOS(
                nibName: Resources.withSuffix("WebView"),
                bundle: Resources.bundle
            )
        #elseif os(macOS)
            guard let webController = WebController_macOS(
                nibName: Resources.withSuffix("WebView"),
                bundle: Resources.bundle
                ) else {
                    return nil
            }
        #endif
        
        let webPresenter = WebPresenterImpl(
            uiSyncQueue: uiSyncQueue,
            controller: webController
        )
        
        DispatchQueue.main.sync {
            self.delegate?.vkNeedToPresent(viewController: webController)
        }
        
        return webPresenter
    }
    
    func captchaPresenter() -> CaptchaPresenter? {
        
        #if os(iOS)
            let captchaController = CaptchaController_iOS(
                nibName: Resources.withSuffix("CaptchaView"),
                bundle: Resources.bundle
            )
        #elseif os(macOS)
            guard let captchaController = CaptchaController_macOS(
                nibName: Resources.withSuffix("CaptchaView"),
                bundle: Resources.bundle
                ) else {
                    return nil
            }
        #endif
        
        let captchaPresenter = CaptchaPresenterImpl(
            uiSyncQueue: uiSyncQueue,
            controller: captchaController
        )
        
        DispatchQueue.main.sync {
            self.delegate?.vkNeedToPresent(viewController: captchaController)
        }
        
        return captchaPresenter
    }
    
    func task(request: Request, callbacks: Callbacks, session: TaskSession) -> Task {
        return TaskImpl(
            request: request,
            callbacks: callbacks,
            session: session,
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
