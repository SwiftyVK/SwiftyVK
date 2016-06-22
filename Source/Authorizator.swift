#if os(OSX)
  import Foundation
#endif
#if os(iOS)
  import UIKit
#endif



private let webAuthorizeUrl = "https://oauth.vk.com/authorize?"
private let redirectUrl = "https://oauth.vk.com/blank.html"



internal struct Authorizator {
  
  
  
  private static var paramsUrl : String {
    let _perm = VK.Scope.toInt(VK.delegate.vkWillAutorize())
    let _mode = isMac ? "mobile" : "ios"
    let _redir = canAutorizeWithVkApp ? "" : "&redirect_uri=\(redirectUrl)"
    
    return  "client_id=\(VK.appID!)&scope=\(_perm)&display=\(_mode)&v\(VK.defaults.apiVersion)&sdk_version=\(VK.defaults.sdkVersion)\(_redir)&response_type=token&revoke=\(Token.revoke ? 1 : 0)"
  }
  
  
  
  internal static func autorize(_ request: Request?) {
    if let request = request {
      request.authFails >= 3 || Token.get() == nil
        ? autorizeWithRequest(request)
        : {_ = request.trySend()}()
    }
    else if Token.get() == nil {
      autorize()
    }
  }
  
  
  
  private static func autorize() {
    Thread.isMainThread()
      ? vkSheetQueue.async(execute: {start(nil)})
      : vkSheetQueue.sync(execute: {start(nil)})
  }
  
  
  
  private static func autorizeWithRequest(_ request: Request) {
    vkSheetQueue.sync(execute: {start(request)})
  }
  
  
  
  private static func start(_ request: Request?) {
    if canAutorizeWithVkApp {
      startWithApp(request)
    }
    else {
      startWithWeb(request)
    }
    
    if VK.state == .authorized {
      request?.isAsynchronous == true ? request?.trySend() : request?.tryInCurrentThread()
    }
    else {
      let err = VK.Error(domain: "VKSDKDomain", code: 2, desc: "User deny authorization", userInfo: nil, req: request)
      request?.attempts = request!.maxAttempts
      request?.errorBlock(error: err)
      DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosBackground).async {
        VK.delegate.vkAutorizationFailed(err)
      }
    }
  }
  
  
  
  private static func startWithWeb(_ request: Request?) {
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
  private let appAuthorizeUrl = "vkauthorize://authorize?"
  
  
  
  private typealias IOSAuthorizator = Authorizator
  extension IOSAuthorizator {
    
    
    
    
    internal static var canAutorizeWithVkApp : Bool {
      return UIApplication.sharedApplication().canOpenURL(NSURL(string: appAuthorizeUrl)!)
        && UIApplication.sharedApplication().canOpenURL(NSURL(string: "vk\(VK.appID)://")!)
    }
    
    
    
    private static func startWithApp(request: Request?) {
      UIApplication.sharedApplication().openURL(NSURL(string: appAuthorizeUrl+paramsUrl)!)
      NSThread.sleepForTimeInterval(1)
      startWithWeb(request)
    }
    
    
    
    internal static func recieveTokenURL(url: NSURL, fromApp app: String?) {
      if (app == "com.vk.vkclient" || app == "com.vk.vkhd" || url.scheme == "vk\(VK.appID)") {
        if url.absoluteString!.containsString("access_token=") {
          _ = Token(urlString: url.absoluteString!)
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
    internal static var canAutorizeWithVkApp : Bool {return false}
    private static func startWithApp(_ request: Request?) {}
    internal static func dropRequest() {}
  }
#endif
