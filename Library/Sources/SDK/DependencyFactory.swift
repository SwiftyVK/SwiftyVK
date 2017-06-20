#if os(OSX)
    import Cocoa
    typealias VKStoryboard = NSStoryboard
#elseif os(iOS)
    import UIKit
    typealias VKStoryboard = UIStoryboard
#endif

protocol DependencyFactory:
    DependencyHolder,
    SessionMaker,
    TaskMaker,
    AttemptMaker,
    TokenMaker,
    WebControllerMaker,
    CaptchaControllerMaker
{}

protocol DependencyHolder: SessionsHolderHolder, AuthorizatorHolder {
    init(appId: String, delegate: SwiftyVKDelegate?)
}

protocol SessionsHolderHolder: class {
    var sessionsHolder: SessionsHolder & SessionSaver { get }
}

protocol AuthorizatorHolder: class {
    var authorizator: Authorizator { get }
}

protocol SessionMaker: class {
    func session(id: String, config: SessionConfig, sessionSaver: SessionSaver) -> Session
}

protocol TaskMaker: class {
    func task(request: Request, callbacks: Callbacks, session: TaskSession & ApiErrorExecutor) -> Task
}

protocol AttemptMaker: class {
    func attempt(request: URLRequest, timeout: TimeInterval, callbacks: AttemptCallbacks) -> Attempt
}

protocol TokenMaker: class {
    func token(token: String, expires: TimeInterval, info: [String : String]) -> Token
}

protocol WebControllerMaker: class {
    func webController() -> WebController?
}

protocol CaptchaControllerMaker {
    func captchaController() -> CaptchaController?
}

final class DependencyFactoryImpl: DependencyFactory {
    
    private let appId: String
    private weak var delegate: SwiftyVKDelegate?
    private let uiSyncQueue = DispatchQueue(label: "SwiftyVK.uiSyncQueue")
    
    init(appId: String, delegate: SwiftyVKDelegate?) {
        self.appId = appId
        self.delegate = delegate
    }
    
    lazy var sessionsHolder: SessionsHolder & SessionSaver = {
        return SessionsHolderImpl(
            sessionMaker: self,
            sessionsStorage: self.sessionsStorage
        )
    }()
    
    lazy var sessionsStorage: SessionsStorage = {
        return SessionsStorageImpl(
            fileManager: FileManager(),
            bundleName: self.bundleName,
            configName: "SwiftyVkState"
        )
    }()
    
    private lazy var bundleName: String = {
        return Bundle.main.infoDictionary?[String(kCFBundleNameKey)] as? String ?? "SwiftyVK"
    }()
    
    func session(id: String, config: SessionConfig, sessionSaver: SessionSaver) -> Session {
        
        let captchaPresenter = CaptchaPresenterImpl(
            uiSyncQueue: uiSyncQueue,
            controllerMaker: self,
            timeout: 600
        )
        
        return SessionImpl(
            id: id,
            config: config,
            taskSheduler: TaskShedulerImpl(),
            attemptSheduler: AttemptShedulerImpl(limit: .limited(3)),
            authorizator: sharedAuthorizator,
            taskMaker: self,
            captchaPresenter: captchaPresenter,
            sessionSaver: sessionSaver,
            delegate: delegate
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
        
        let tokenStorge = TokenStorageImpl(serviceKey: self.bundleName)
        
        let vkAppProxy = VkAppProxyImpl(
            appId: self.appId,
            urlOpener: urlOpener
        )
        
        let webPresenter = WebPresenterImpl(
            uiSyncQueue: self.uiSyncQueue,
            controllerMaker: self,
            maxFails: 3,
            timeout: 600
        )
        
        return AuthorizatorImpl(
            appId: self.appId,
            delegate: self.delegate,
            tokenStorage: tokenStorge,
            tokenMaker: self,
            tokenParser: TokenParserImpl(),
            vkAppProxy: vkAppProxy,
            webPresenter: webPresenter
        )
    }()
    
    func webController() -> WebController? {
        var webController: WebController?
        
        #if os(iOS)
            webController = storyboard().instantiateViewController(withIdentifier: "Web") as? WebController_iOS
        #elseif os(macOS)
            webController = storyboard().instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Web")) as? WebController_macOS
        #endif
        
        guard let controller = webController as? VKViewController else {
            return nil
        }
        
        DispatchQueue.main.sync {
            self.delegate?.vkNeedToPresent(viewController: controller)
        }
        
        return webController
    }
    
    func captchaController() -> CaptchaController? {
        var captchaController: CaptchaController?
        
        #if os(iOS)
            captchaController = storyboard().instantiateViewController(withIdentifier: "Captcha") as? CaptchaController_iOS
        #elseif os(macOS)
            captchaController = storyboard().instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Captcha")) as? CaptchaController_macOS
        #endif
        
        guard let controller = captchaController as? VKViewController else {
            return nil
        }
        
        DispatchQueue.main.sync {
            self.delegate?.vkNeedToPresent(viewController: controller)
        }
        
        return captchaController
    }
    
    func storyboard() -> VKStoryboard {
        #if os(OSX)
            let name = NSStoryboard.Name(rawValue: Resources.withSuffix("Storyboard"))
        #elseif os(iOS)
            let name = Resources.withSuffix("Storyboard")
        #endif
        
        return VKStoryboard(
            name: name,
            bundle: Resources.bundle
        )
    }
    
    func task(request: Request, callbacks: Callbacks, session: TaskSession & ApiErrorExecutor) -> Task {
        return TaskImpl(
            request: request,
            callbacks: callbacks,
            session: session,
            urlRequestBuilder: urlRequestBuilder(),
            attemptMaker: self,
            apiErrorHandler: ApiErrorHandlerImpl(session: session)
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
