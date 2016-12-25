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
    func vkWillAuthorize() -> Set<VK.Scope>
    ///Called when SwiftyVK did authorize and receive token
    func vkDidAuthorizeWith(parameters: [String : String])
    ///Called when SwiftyVK did unauthorize and remove token
    func vkDidUnauthorize()
    ///Called when SwiftyVK did failed autorization
    func vkAutorizationFailedWith(error: AuthError)
    /** ---DEPRECATED. TOKEN NOW STORED IN KEYCHAIN--- Called when SwiftyVK need know where a token is located
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
    internal weak static var delegate: VKDelegate?
    public private(set) static var appID: String?



    /**
     Initialize library with identifier and application delegate
     - parameter appID: application ID
     - parameter delegate: Delegate corresponding protocol VKDelegate
     */
    public static func configure(withAppId id: String, delegate owner: VKDelegate) {
        delegate = owner
        appID    = id
        _ = Token.get()
        VK.Log.put("Global", "SwiftyVK configured")
    }



    /**
     Getting authenticate token.
     * If the token is already stored in the file, then the authentication takes place in the background
     * If not, shows a pop-up notification with authorization request
     */
    public static func logIn() {
        _ = Authorizator.authorize()
    }



    #if os(iOS)
    public static func process(url: URL, sourceApplication app: String?) {
        Authorizator.recieveTokenURL(url: url, fromApp: app)
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
// MARK: - States
extension VK {
    public enum States: Int, Comparable {
        case unknown = 0
        case configured = 1
        //        case authorization
        case authorized = 2
    }
    
    

    public static var state: States {
        guard VK.delegate != nil && VK.appID != nil else {
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
// MARK: - Extensions
extension VK {
    ///Access to the API methods
    public typealias API = _VKAPI
    public typealias SuccessBlock = (_ response: JSON) -> ()
    public typealias ErrorBlock = (_ error: Swift.Error) -> ()
    public typealias ProgressBlock = (_ done: Int64, _ total: Int64) -> ()
}



public func > (lhs: VK.States, rhs: VK.States) -> Bool {
    return lhs.rawValue > rhs.rawValue
}



public func >= (lhs: VK.States, rhs: VK.States) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}



public func < (lhs: VK.States, rhs: VK.States) -> Bool {
    return lhs.rawValue < rhs.rawValue
}



public func <= (lhs: VK.States, rhs: VK.States) -> Bool {
    return lhs.rawValue <= rhs.rawValue
}
