#if os(macOS)
    import Cocoa
    typealias VKStoryboard = NSStoryboard
#elseif os(iOS)
    import UIKit
    typealias VKStoryboard = UIStoryboard
#endif

final class DependenciesImpl: Dependencies {
    
    private let appId: String
    private weak var delegate: SwiftyVKDelegate?
    
    private let longPollTaskTimeout: TimeInterval = 30
    private let uiSyncQueue = DispatchQueue(label: "SwiftyVK.uiSyncQueue")
    
    private lazy var foregroundSession: VKURLSession = {
        let config = URLSessionConfiguration.default
        
        if #available(OSX 10.13, iOS 11.0, *) {
            config.waitsForConnectivity = true
        }
        
        return URLSession(configuration: config)
    }()
    
    private lazy var connectionObserver: ConnectionObserver? = {
        guard let reachability = Reachability() else { return nil }
        
        #if os(iOS)
            let appStateCenter = NotificationCenter.default
            let activeNotificationName = Notification.Name.UIApplicationDidBecomeActive
            let inactiveNotificationName = Notification.Name.UIApplicationWillResignActive
        #elseif os(macOS)
            let appStateCenter = NSWorkspace.shared.notificationCenter
            let activeNotificationName = NSWorkspace.willSleepNotification
            let inactiveNotificationName = NSWorkspace.didWakeNotification
        #endif
        
        return ConnectionObserverImpl(
            appStateCenter: appStateCenter,
            reachabilityCenter: NotificationCenter.default,
            reachability: reachability,
            activeNotificationName: activeNotificationName,
            inactiveNotificationName: inactiveNotificationName,
            reachabilityNotificationName: ReachabilityChangedNotification
        )
    }()
    
    private lazy var cookiesHolder: CookiesHolder = {
        CookiesHolderImpl(
            vkStorage: CookiesStorageImpl(serviceKey: self.bundleName + "_Cookies"),
            sharedStorage: HTTPCookieStorage.shared
        )
    }()
    
    init(appId: String, delegate: SwiftyVKDelegate?) {
        self.appId = appId
        self.delegate = delegate
    }
    
    lazy var sessionsHolder: SessionsHolder & SessionSaver = {
        SessionsHolderImpl(
            sessionMaker: self,
            sessionsStorage: self.sessionsStorage
        )
    }()
    
    lazy var sessionsStorage: SessionsStorage = {
        SessionsStorageImpl(
            fileManager: FileManager(),
            bundleName: self.bundleName,
            configName: "SwiftyVKState"
        )
    }()
    
    lazy var idGenerator: IDGenerator = {
        IDGeneratorImpl()
    }()
    
    private lazy var bundleName: String = {
        Bundle.main.infoDictionary?[String(kCFBundleNameKey)] as? String ?? "SwiftyVK"
    }()
    
    func session(id: String, config: SessionConfig, sessionSaver: SessionSaver) -> Session {
        
        let captchaPresenter = CaptchaPresenterImpl(
            uiSyncQueue: uiSyncQueue,
            controllerMaker: self,
            timeout: 600,
            urlSession: foregroundSession
        )
        
        return SessionImpl(
            id: id,
            config: config,
            taskSheduler: TaskShedulerImpl(),
            attemptSheduler: AttemptShedulerImpl(limit: 3),
            authorizator: sharedAuthorizator,
            taskMaker: self,
            captchaPresenter: captchaPresenter,
            sessionSaver: sessionSaver,
            longPollMaker: self,
            delegate: delegate
        )
    }
    
    var authorizator: Authorizator {
        return sharedAuthorizator
    }
    
    private lazy var sharedAuthorizator: Authorizator = {
        
        let urlOpener: URLOpener
        
        #if os(iOS)
            urlOpener = UIApplication.shared
        #elseif os(macOS)
            urlOpener = URLOpenerMacOS()
        #endif
        
        let tokenStorge = TokenStorageImpl(serviceKey: self.bundleName + "_Token")
        
        let vkAppProxy = VKAppProxyImpl(
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
            webPresenter: webPresenter,
            cookiesHolder: nil
        )
    }()
    
    func webController() -> WebController? {
        var webController: WebController?
        
        #if os(iOS)
            webController = storyboard().instantiateViewController(withIdentifier: "Web") as? WebControllerIOS
        #elseif os(macOS)
            webController = storyboard().instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Web")
                ) as? WebControllerMacOS
        #endif
        
        guard let controller = webController as? VKViewController else {
            return nil
        }
        
        DispatchQueue.performOnMainIfNeeded {
            self.delegate?.vkNeedToPresent(viewController: controller)
        }
        
        return webController
    }
    
    func captchaController() -> CaptchaController? {
        var captchaController: CaptchaController?
        
        #if os(iOS)
            captchaController = storyboard().instantiateViewController(
                withIdentifier: "Captcha"
                ) as? CaptchaControllerIOS
        #elseif os(macOS)
            captchaController = storyboard().instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Captcha")
                ) as? CaptchaControllerMacOS
        #endif
        
        guard let controller = captchaController as? VKViewController else {
            return nil
        }
        
        DispatchQueue.performOnMainIfNeeded {
            self.delegate?.vkNeedToPresent(viewController: controller)
        }
        
        return captchaController
    }
    
    func storyboard() -> VKStoryboard {
        #if os(macOS)
            let name = NSStoryboard.Name(rawValue: Resources.withSuffix("Storyboard"))
        #elseif os(iOS)
            let name = Resources.withSuffix("Storyboard")
        #endif
        
        return VKStoryboard(
            name: name,
            bundle: Resources.bundle
        )
    }
    
    func task(request: Request, session: TaskSession & ApiErrorExecutor) -> Task {
        return TaskImpl(
            id: idGenerator.next(),
            request: request,
            session: session,
            urlRequestBuilder: urlRequestBuilder(),
            attemptMaker: self,
            apiErrorHandler: ApiErrorHandlerImpl(executor: session)
        )
    }
    
    func attempt(request: URLRequest, callbacks: AttemptCallbacks) -> Attempt {
        return AttemptImpl(
            request: request,
            session: foregroundSession,
            callbacks: callbacks
        )
    }
    
    func longPollTask(session: Session?, data: LongPollTaskData) -> LongPollTask {
        return LongPollTaskImpl(
            session: session,
            delayOnError: longPollTaskTimeout,
            data: data
        )
    }
    
    func longPoll(session: Session) -> LongPoll {
        return LongPollImpl(
            session: session,
            operationMaker: self,
            connectionObserver: connectionObserver,
            getInfoDelay: 3
        )
    }
    
    func token(token: String, expires: TimeInterval, info: [String: String]) -> Token {
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
