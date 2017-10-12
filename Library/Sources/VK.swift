public final class VK {
    public static func prepareForUse(appId: String, delegate: SwiftyVKDelegate) {
        guard factory == nil else {
            return
        }
        
        factory = factoryType.init(appId: appId, delegate: delegate)
    }
    
    public static var sessions: SessionsHolder? {
        return factory?.sessionsHolder
    }

    static var factoryType: DependencyHolder.Type = DependenciesImpl.self
    private static var factory: DependencyHolder?
 
    #if os(iOS)
    public static func handle(url: URL, sourceApplication app: String?) {
        factory?.authorizator.handle(url: url, app: app)
    }
    #endif
}
