#if os(OSX)
  import Foundation
#endif
#if os(iOS)
  import UIKit
#endif



private let webAuthorizeUrl = "https://oauth.vk.com/authorize?"
private let redirectUrl = "https://oauth.vk.com/blank.html"
private let appAuthorizeUrl = "vkauthorize://authorize?"



internal struct Authorizator {
  
  
  
  fileprivate static var paramsUrl : String {
    let _perm = VK.Scope.toInt(VK.delegate!.vkWillAuthorize())
    let _mode = isMac ? "mobile" : "ios"
    let _redir = canAuthorizeWithVkApp ? "" : "&redirect_uri=\(redirectUrl)"
    
    return  "client_id=\(VK.appID!)&scope=\(_perm)&display=\(_mode)&v\(VK.defaults.apiVersion)&sdk_version=\(VK.defaults.sdkVersion)\(_redir)&response_type=token&revoke=\(Token.revoke ? 1 : 0)"
  }
  
  
  
  internal static func authorize(_ request: Request?) {
    if let request = request {
      request.authFails >= 3 || Token.get() == nil
        ? authorizeWithRequest(request)
        : {_ = request.trySend()}()
    }
    else if Token.get() == nil {
      authorize()
    }
  }
  
  
  
  private static func authorize() {
    Thread.isMainThread
      ? vkSheetQueue.async {start(nil)}
      : vkSheetQueue.sync {start(nil)}
  }
  
  
  
  private static func authorizeWithRequest(_ request: Request) {
    vkSheetQueue.sync(execute: {start(request)})
  }
  
  
  
  private static func start(_ request: Request?) {
    if canAuthorizeWithVkApp {
      startWithApp(request)
    }
    else {
      startWithWeb(request)
    }
    
    if VK.state == .authorized {
      _ = request?.asynchronous == true ? request?.trySend() : request?.tryInCurrentThread()
    }
    else {
      let err = VK.Error(domain: "SwiftyVKDomain", code: 2, desc: "User deny authorization", userInfo: nil, req: request)
      request?.attempts = request!.maxAttempts
      request?.errorBlock(err)
      DispatchQueue.global(qos: .default).async {
        VK.delegate?.vkAutorizationFailedWith(error: err)
      }
    }
  }
  
  
  
  fileprivate static func startWithWeb(_ request: Request?) {
    WebController.start(url: webAuthorizeUrl+paramsUrl, request: nil)
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
//
#if os(iOS)
  private typealias IOSAuthorizator = Authorizator
  extension IOSAuthorizator {
    
    
    
    internal static var canAuthorizeWithVkApp : Bool {
      return UIApplication.shared.canOpenURL(URL(string: appAuthorizeUrl)!)
        && UIApplication.shared.canOpenURL(URL(string: "vk\(VK.appID!)://")!)
    }
    
    
    
    fileprivate static func startWithApp(_ request: Request?) {
      UIApplication.shared.openURL(URL(string: appAuthorizeUrl+paramsUrl)!)
      Thread.sleep(forTimeInterval: 1)
      startWithWeb(request)
    }
    
    
    
    internal static func recieveTokenURL(url: URL, fromApp app: String?) {
      if (app == "com.vk.vkclient" || app == "com.vk.vkhd" || url.scheme == "vk\(VK.appID)") {
        if url.absoluteString.contains("access_token=") {
          _ = Token(urlString: url.absoluteString)
          WebController.cancel()
        }
      }
    }
  }
#endif
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
//
#if os(OSX)
  private typealias OSXAuthorizator = Authorizator
  extension OSXAuthorizator {
    internal static var canAuthorizeWithVkApp : Bool {return false}
    fileprivate static func startWithApp(_ request: Request?) {}
  }
#endif
