public final class VK {
    public static func setUp(appId: String, delegate: SwiftyVKDelegate) {
        guard dependencies == nil else {
            return
        }
        
        dependencies = dependenciesType.init(appId: appId, delegate: delegate)
    }
    
    public static var sessions: SessionsHolder? {
        return dependencies?.sessionsHolder
    }

    static var dependenciesType: DependenciesHolder.Type = DependenciesImpl.self
    private static var dependencies: DependenciesHolder?
 
    #if os(iOS)
    public static func handle(url: URL, sourceApplication app: String?) {
        dependencies?.authorizator.handle(url: url, app: app)
    }
    #endif
}
