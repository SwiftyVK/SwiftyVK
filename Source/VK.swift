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
  func vkDidAutorize()
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
  internal static var delegate : VKDelegate!
  internal static var appID : String!
  /**
  Initialize library with identifier and application delegate
  - parameter appID: application ID
  - parameter delegate: Delegate corresponding protocol VKDelegate
  */
  public static func start(appID id: String, delegate owner: VKDelegate) {
    delegate = owner
    appID    = id
    Log([.all], "SwiftyVK did INIT")
  }
  /**
  Getting authenticate token.
  * If the token is already stored in the file, then the authentication takes place in the background
  * If not, shows a pop-up notification with authorization request
  */
  public static func autorize() {
    autorize(nil);
  }
  
  
  
  internal static func autorize(request: Request?) {
    assert(delegate != nil && appID != nil , "At first initialize VK with start() method")
    
    if let _ = Token.loadToken() {
      if let request = request {
        request.reSend()
      }
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {VK.delegate.vkDidAutorize()}
    }
    else if let request = request {
      WebController.autorizeWithRequest(request)
    }
    else {
      WebController.autorize(true)
    }
  }
  
  
  
  public static func logOut() {
    delegate.vkDidUnautorize()
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
    public static let apiVersion = "5.37"
    ///Log options to trace API work
    public static var logOptions : [LogOption] = []
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
    public static var language : String? {
      get {
        if useSystemLanguage {
          let syslemLang = NSLocale.preferredLanguages()[0] as String
          
          if supportedLanguages.contains(syslemLang) {
            return syslemLang
          }
          else if syslemLang == "uk" {
            return "ua"
          }
        }
        return self.privateLanguage
      }
      set {
        self.privateLanguage = newValue
        useSystemLanguage = false
      }
    }
    internal static var sleepTime : NSTimeInterval {return NSTimeInterval(1/Double(maxRequestsPerSec))}
    internal static let successBlock : VK.SuccessBlock = {response in}
    internal static let errorBlock : VK.ErrorBlock = {error in}
    internal static let progressBlock : VK.ProgressBlock = {Int in}
    internal static let supportedLanguages = ["ru", "en", "ua", "es", "fi", "de", "it"]
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
private typealias VK_Extensions = VK
extension VK_Extensions {
  ///Access to the API methods
  public typealias API = _VKAPI
  public typealias Error = _VKError
  public typealias SuccessBlock = (response: JSON) -> Void
  public typealias ErrorBlock = (error: VK.Error) -> Void
  public typealias ProgressBlock = (done: Int, total: Int) -> Void
}