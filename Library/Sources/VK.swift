import Foundation
#if os(iOS)
    import UIKit
    public typealias VkViewController = UIViewController
#elseif os(OSX)
    import Cocoa
    public typealias VkViewController = NSViewController
#endif

public final class VK {
    
    public struct Api {
        private init() {}
    }
    
    public static func prepareForUse(appId: String, delegate: SwiftyVKDelegate) {
        guard dependencyHolder == nil else {
            return
        }
        
        dependencyHolder = dependencyHolderInstanceType.init(appId: appId, delegate: delegate)
    }
    
    public static var sessions: SessionsHolder? {
        return dependencyHolder?.sessionsHolder
    }

    static var dependencyHolderInstanceType: DependencyHolder.Type = DependencyFactoryImpl.self
    private static var dependencyHolder: DependencyHolder?
 
    #if os(iOS)
    public static func handle(url: URL, sourceApplication app: String?) {
        dependencyHolder?.authorizator.handle(url: url, app: app)
    }
    #endif
}
