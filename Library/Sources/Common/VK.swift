import Foundation

/// SwiftyVK entry point
public final class VK {
    public static func setUp(appId: String, delegate: SwiftyVKDelegate,
							 bundleName: String? = nil, configPath: String? = nil) {
        guard dependencies == nil else {
            return
        }
        
        dependencies = dependenciesType.init(appId: appId, delegate: delegate,
											 bundleName: bundleName, configPath: configPath)
    }
    
    /// Returns SwiftyVK user sessions
    public static var sessions: SessionsHolder {
        guard let sessionsHolder = dependencies?.sessionsHolder else {
            fatalError("You must call VK.setUp function to start using SwiftyVK!")
        }
        
        return sessionsHolder
    }

    static var dependenciesType: DependenciesHolder.Type = DependenciesImpl.self
    private static var dependencies: DependenciesHolder?
 
    #if os(iOS)
    public static func handle(url: URL, sourceApplication app: String?) {
        dependencies?.authorizator.handle(url: url, app: app)
    }
    #endif
}
