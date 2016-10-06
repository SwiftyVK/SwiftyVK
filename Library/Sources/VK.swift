import Foundation
#if os(iOS)
    import UIKit
#endif
#if os(OSX)
    import Cocoa
#endif


///Delegate to the SwiftyVK
public protocol VKDelegate: class {
    /**Called when SwiftyVK need autorization permissions
     - returns: permissions as VK.Scope type*/
    func vkWillAuthorize() -> [VK.Scope]
    ///Called when SwiftyVK did authorize and receive token
    func vkDidAuthorizeWith(parameters: [String : String])
    ///Called when SwiftyVK did unauthorize and remove token
    func vkDidUnauthorize()
    ///Called when SwiftyVK did failed autorization
    func vkAutorizationFailedWith(error: VKAuthError)
    /**Called when SwiftyVK need know where a token is located
     - returns: Path to save/read token or nil if should save token to UserDefaults*/
    func vkShouldUseTokenPath() -> String?
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
/**
 Library to connect to the social network "VKontakte"
 * To use, you must call configure() specifying the application ID and a delegate
 * For user authentication you must call authorize()
 */
public struct VK {
    internal static var delegate : VKDelegate? {
        set{delegateInstance = newValue}
        get{assert(VK.state != .unknown, "At first initialize VK with configure() method")
            return delegateInstance}
    }
    public private(set) static var appID : String? {
        set{appIDInstance = newValue}
        get{assert(VK.state != .unknown, "At first initialize VK with configure() method")
            return appIDInstance}
    }
    private static weak var delegateInstance : VKDelegate?
    private static var appIDInstance : String?
    
    

    /**
     Initialize library with identifier and application delegate
     - parameter appID: application ID
     - parameter delegate: Delegate corresponding protocol VKDelegate
     */
    public static func configure(appID id: String, delegate owner: VKDelegate) {
        delegate = owner
        appID    = id
        _ = Token.get()
         VK.Log.put("Global", "SwiftyVK configured")
    }
    
    
    
    fileprivate static var configured : Bool {
        return VK.delegateInstance != nil && VK.appIDInstance != nil
    }
    

    
    /**
     Getting authenticate token.
     * If the token is already stored in the file, then the authentication takes place in the background
     * If not, shows a pop-up notification with authorization request
     */
    public static func logIn() {
        Authorizator.authorize(nil);
    }
    
    
    
    #if os(iOS)
    @available(iOS 9.0, *)
    public static func processURL(url: URL, options: [AnyHashable: Any]) {
    Authorizator.recieveTokenURL(url: url, fromApp: options[UIApplicationOpenURLOptionsKey.sourceApplication.rawValue] as? String);
    }
    
    
    @available(iOS, introduced:4.2, deprecated:9.0, message:"Please use url:options:")
    public static func processURL_old(url: URL, sourceApplication app: String?) {
    Authorizator.recieveTokenURL(url: url, fromApp: app);
    }
    #endif
    
    
    
    public static func logOut() {
        LP.stop()
        Token.remove()
    }
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
//MARK: - States
extension VK {
    public enum States {
        case unknown
        case configured
//        case authorization
        case authorized
    }
    
    public static var state : States {
        guard VK.configured else {
            return .unknown
        }
        guard Token.exist else {
            return .configured
        }
        return .authorized
    }
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
//MARK: - Extensions
extension VK {
    ///Access to the API methods
    public typealias API = _VKAPI
    public typealias SuccessBlock = (_ response: JSON) -> ()
    public typealias ErrorBlock = (_ error: Error) -> ()
    public typealias ProgressBlock = (_ done: Int64, _ total: Int64) -> ()
}
