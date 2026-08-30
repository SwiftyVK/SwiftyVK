import Foundation

/// SwiftyVK entry point
public final class VK {
    public static func setUp(
            appId: String,
            delegate: SwiftyVKDelegate,
            bundleName: String? = nil,
            configPath: String? = nil
    ) {
        guard dependencies == nil else {
            return
        }
        
        dependencies = dependenciesType.init(
            appId: appId,
            delegate: delegate,
            bundleName: bundleName,
            configPath: configPath
        )
    }

    #if compiler(>=5.5)
    /// Sets up SwiftyVK with closure-based event handling.
    /// `onViewNeedsToPresent` receives controllers that the app should present.
    /// `tokenEvents` selects one way to receive token lifecycle events.
    @available(iOS 13.0, macOS 10.15, *)
    public static func setUp(
        appId: String,
        scopeProvider: @escaping (String) -> Scopes,
        onViewNeedsToPresent: @escaping (VKViewController) -> Void,
        tokenEvents: VKTokenEventsHandler? = nil,
        bundleName: String? = nil,
        configPath: String? = nil
    ) {
        guard dependencies == nil else {
            return
        }

        let delegate = SwiftyVKClosureDelegate(
            scopeProvider: scopeProvider,
            onViewNeedsToPresent: onViewNeedsToPresent,
            tokenEvents: tokenEvents
        )

        retainedClosureDelegate = delegate
        dependencies = dependenciesType.init(
            appId: appId,
            delegate: delegate,
            bundleName: bundleName,
            configPath: configPath
        )
    }
    #endif
    
    /// Returns SwiftyVK user sessions
    public static var sessions: SessionsHolder {
        guard let sessionsHolder = dependencies?.sessionsHolder else {
            fatalError("You must call VK.setUp function to start using SwiftyVK!")
        }
        
        return sessionsHolder
    }

    /// Does `VK.setUp` already called
    public static var needToSetUp: Bool {
        dependencies?.sessionsHolder == nil
    }

    /// Free up all SwiftyVK's resources and release memory
    /// Call it only if you won't interact with the library anymore
    /// If you'll need to work with the library again after calling this method, you should call setUp
    public static func release() {
        dependencies = nil

        #if compiler(>=5.5)
        if #available(iOS 13.0, macOS 10.15, *) {
            retainedClosureDelegate?.finishTokenEvents()
            retainedClosureDelegate = nil
        }
        #endif
    }

    static var dependenciesType: DependenciesHolder.Type = DependenciesImpl.self
    private static var dependencies: DependenciesHolder?

    #if compiler(>=5.5)
    /// Retains the closure-based delegate because dependencies store delegates weakly.
    @available(iOS 13.0, macOS 10.15, *)
    private static var retainedClosureDelegate: SwiftyVKClosureDelegate?
    #endif
 
    #if os(iOS)
    public static func handle(url: URL, sourceApplication app: String?) {
        dependencies?.authorizator.handle(url: url, app: app)
    }
    #endif
}
