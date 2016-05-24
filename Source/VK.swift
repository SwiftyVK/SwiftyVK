import Foundation
#if os(iOS)
  import UIKit
#endif
#if os(OSX)
  import Cocoa
#endif


///Delegate to the SwiftyVK
public protocol VKDelegate {
  /**Called when SwiftyVK need autorization permissions
   - returns: permissions as VK.Scope type*/
  func vkWillAutorize() -> [VK.Scope]
  ///Called when SwiftyVK did autorize and receive token
  func vkDidAutorize(parameters: Dictionary<String, String>)
  ///Called when SwiftyVK did unautorize and remove token
  func vkDidUnautorize()
  ///Called when SwiftyVK did failed autorization
  func vkAutorizationFailed(_: VK.Error)
  /**Called when SwiftyVK need know where a token is located
   - returns: Bool value that indicates whether to save token to user defaults or not, and alternative save path*/
  func vkTokenPath() -> (useUserDefaults: Bool, alternativePath: String)
  #if os(iOS)
  /**Called when need to display a view from SwiftyVK
   - returns: UIViewController that should present autorization view controller*/
  func vkWillPresentView() -> UIViewController
  #elseif os(OSX)
  /**Called when need to display a window from SwiftyVK
   - returns: Bool value that indicates whether to display the window as modal or not, and parent window for modal presentation.*/
  func vkWillPresentWindow() -> (isSheet: Bool, inWindow: NSWindow?)
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
 * To use, you must call start() specifying the application ID and a delegate
 * For user authentication you must call autorize()
 */
public struct VK {
  internal static var delegate : VKDelegate! {
    set{delegateInstance = newValue}
    get{assert(VK.state != .Unknown, "At first initialize VK with start() method")
    return delegateInstance}
  }
  public private(set) static var appID : String! {
    set{appIDInstance = newValue}
    get{assert(VK.state != .Unknown, "At first initialize VK with start() method")
    return appIDInstance}
  }
  private static var delegateInstance : VKDelegate?
  private static var appIDInstance : String?
  
  /**
   Initialize library with identifier and application delegate
   - parameter appID: application ID
   - parameter delegate: Delegate corresponding protocol VKDelegate
   */
  public static func start(appID id: String, delegate owner: VKDelegate) {
    delegate = owner
    appID    = id
    Token.get()
    VK.Log.put("Global", "SwiftyVK INIT")
  }
  
  private static var started : Bool {
    return VK.delegateInstance != nil && VK.appIDInstance != nil
  }
  /**
   Getting authenticate token.
   * If the token is already stored in the file, then the authentication takes place in the background
   * If not, shows a pop-up notification with authorization request
   */
  public static func autorize() {
    Authorizator.autorize(nil);
  }
  
  
  
  #if os(iOS)
  @available(iOS 9.0, *)
  public static func processURL(url: NSURL, options: [String: AnyObject]) {
  Authorizator.recieveTokenURL(url, fromApp: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String);
  }
  
  
  @available(iOS, introduced=4.2, deprecated=9.0, message="Please use url:options:")
  public static func processURL_old(url: NSURL, sourceApplication app: String?) {
  Authorizator.recieveTokenURL(url, fromApp: app);
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
private typealias VK_Defaults = VK
extension VK_Defaults {
  public struct defaults {
    //Returns used VK API version
    public static let apiVersion = "5.52"
    //Returns used VK SDK version
    public static let sdkVersion = "1.3.1"
    ///Requests timeout
    public static var timeOut : Int = 10
    ///Maximum number of attempts to send requests
    public static var maxAttempts : Int = 3
    ///Whether to allow automatic processing of some API error
    public static var catchErrors : Bool = true
    //Similarly request sendAsynchronous property
    public static var sendAsynchronous : Bool = true
    ///Maximum number of requests per second
    public static var maxRequestsPerSec : Int = 3
    ///Allows print log messages to console
    public static var allowLogToConsole : Bool = false
    
    public static var language : String? {
      get {
      if useSystemLanguage {
      let syslemLang = NSBundle.preferredLocalizationsFromArray(supportedLanguages).first
      
      if syslemLang == "uk" {
      return "ua"
      }
      
      return syslemLang
      }
      return self.privateLanguage
      }
      
      set {
        guard newValue == nil || supportedLanguages.contains(newValue!) else {return}
        self.privateLanguage = newValue
        useSystemLanguage = (newValue == nil)
      }
    }
    internal static var sleepTime : NSTimeInterval {return NSTimeInterval(1/Double(maxRequestsPerSec))}
    internal static let successBlock : VK.SuccessBlock = {success in}
    internal static let errorBlock : VK.ErrorBlock = {error in}
    internal static let progressBlock : VK.ProgressBlock = {int in}
    internal static let supportedLanguages = ["ru", "uk", "be", "en", "es", "fi", "de", "it"]
    internal static var useSystemLanguage = true
    private static var privateLanguage : String?
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


public typealias VK_States = VK
extension VK_States {
  public enum States {
    case Unknown
    case Started
    case inAutorization
    case Authorized
  }
  
  public static var state : States {
    guard VK.started else {
      return .Unknown
    }
    guard Token.exist else {
      return .Started
    }
    return .Authorized
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
private typealias VK_Extensions = VK
extension VK_Extensions {
  ///Access to the API methods
  public typealias API = _VKAPI
  public typealias Error = _VKError
  public typealias SuccessBlock = (response: JSON) -> Void
  public typealias ErrorBlock = (error: VK.Error) -> Void
  public typealias ProgressBlock = (done: Int, total: Int) -> Void
}