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
/**
 Library to connect to the social network "VKontakte"
 * To use, you must call configure() specifying the application ID and a delegate
 * For user authentication you must call authorize()
 */
public struct VK {
    
    public struct Api {
        private init() {}
    }
    
    public internal(set) static var sessions: SessionStorage = {
        assert(appId != nil, "You should initialize SwiftyVK first with VK.initializeWith(_:_:)")
        return DependencyBoxImpl().sessionStorage
    }()
    
    static var delegate: SwiftyVKDelegate?
    weak static var legacyDelegate: LegacyVKDelegate?
    public private(set) static var appId: String?

    public static func initializeWith(appId: String, delegate: SwiftyVKDelegate) {
        self.appId = appId
        self.delegate = delegate
    }
 
    #if os(iOS)
    public static func process(url: URL, sourceApplication app: String?) {
//        LegacyAuthorizator.recieveTokenURL(url: url, fromApp: app)
    }
    #endif
}
