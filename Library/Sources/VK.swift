import Foundation
#if os(iOS)
    import UIKit
    public typealias Displayer = UIWindow
#elseif os(OSX)
    import Cocoa
    public typealias Displayer = NSWindow
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
    func vkWillPresentView() -> Displayer?
    func vkWillLogIn(in session: Session) -> Scopes
    func vkLogInDidSuccess(in session: Session, with parameters: [String : String])
    func vkLogInDidFail(in session: Session, with error: Error)
    func vkDidLogOut(in session: Session)
}
/**
 Library to connect to the social network "VKontakte"
 * To use, you must call configure() specifying the application ID and a delegate
 * For user authentication you must call authorize()
 */
public struct VK {
    public internal(set) static var sessions: SessionManager = {
        assert(appId != nil, "You should initialize SwiftyVK first with VK.initializeWith(_:_:)")
        return DependencyBoxImpl().sessionManager
    }()
    
    static var delegate: SwiftyVKDelegate?
    weak static var legacyDelegate: LegacyVKDelegate?
    public private(set) static var appId: String?

    public static func initializeWith(appId: String, delegate: SwiftyVKDelegate) {
        self.appId = appId
        self.delegate = delegate
    }
    /**
     Initialize library with identifier and application delegate
     - parameter appID: application ID
     - parameter delegate: Delegate corresponding protocol VKDelegate
     */
    public static func configure(withAppId id: String, delegate owner: LegacyVKDelegate) {
        legacyDelegate = owner
        appId    = id
        _ = LegacyToken.get()
        VK.Log.put("Global", "SwiftyVK configured")
    }

    /**
     Gets authenticate token.
     * If the token is already stored in the file, then the authentication takes place in the background
     * If not, shows a pop-up notification with authorization request
     */
    public static func logIn() {
        _ = LegacyAuthorizator.authorize()
    }
    
    /**
     Creates a token from string
     - parameter rawToken: token string repersented e.g. "487tajfalsf476tir0jfao4804slrjgsf3"
     - parameter expiresIn: expiry time in milliseconds from now. By default = 0 (infinite token)
     */
    public static func logInWith(rawToken: String, expiresIn: Int = 0) {
        LegacyAuthorizator.authorizeWith(rawToken: rawToken, expiresIn: expiresIn)
    }

    #if os(iOS)
    public static func process(url: URL, sourceApplication app: String?) {
        Authorizator.recieveTokenURL(url: url, fromApp: app)
    }
    #endif

    public static func logOut() {
        LP.stop()
        LegacyToken.remove()
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
        // case authorization
        case authorized = 2
        // equatable
        public static func == (lhs: VK.States, rhs: VK.States) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        // comparable
        public static func < (lhs: VK.States, rhs: VK.States) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    public static var state: States {
        guard VK.legacyDelegate != nil && VK.appId != nil else {
            return .unknown
        }
        guard LegacyToken.exist else {
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
    
    public struct Api {
        private init() {}
    }
}
