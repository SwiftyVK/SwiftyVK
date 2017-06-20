import Foundation
#if os(iOS)
    import UIKit
    public typealias VkViewController = UIViewController
#elseif os(OSX)
    import Cocoa
    public typealias VkViewController = NSViewController
#endif

///Delegate to the SwiftyVK
public protocol LegacyVKDelegate: class {
    /**Called when SwiftyVK need autorization permissions
     - returns: permissions as VK.Scope type*/
    func vkWillAuthorize() -> Set<VK.Scope>
    ///Called when SwiftyVK did authorize and receive token
    func vkDidAuthorizeWith(parameters: [String : String])
    ///Called when SwiftyVK did unauthorize and remove token
    func vkDidUnauthorize()
    ///Called when SwiftyVK did failed autorization
    func vkAutorizationFailedWith(error: SessionError)
    #if os(iOS)
    /**Called when need to display a view from SwiftyVK
     - returns: UIViewController that should present autorization view controller*/
    func vkWillPresentView() -> UIViewController
    #elseif os(OSX)
    /**Called when need to display a view from SwiftyVK
     - returns: Parent window for modal view or nil if view should present in separate window.*/
    func vkWillPresentView() -> NSWindow?
    #endif
}
//
//
//
//
//
//
//
//
//
//
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
    
    weak static var legacyDelegate: LegacyVKDelegate?
}
