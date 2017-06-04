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
public protocol SwiftyVKDelegate: class {
    func vkNeedToPresent(viewController: VkViewController)
    func vkWillLogIn(in session: Session) -> Scopes
    func vkDidLogOut(in session: Session)
}


public final class VK {
    
    public struct Api {
        private init() {}
    }
    
    public static func prepareForUse(appId: String, delegate: SwiftyVKDelegate) {
        dependencyHolder = DependencyFactoryImpl(appId: appId, delegate: delegate)
    }
    
    public static var sessions: SessionStorage? {
        return dependencyHolder?.sessionStorage
    }

    private static var dependencyHolder: (SessionStorageHolder & AuthorizatorHolder)?
 
    #if os(iOS)
    public static func process(url: URL, sourceApplication app: String?) {
//        LegacyAuthorizator.recieveTokenURL(url: url, fromApp: app)
    }
    #endif
    
    weak static var legacyDelegate: LegacyVKDelegate?
}
