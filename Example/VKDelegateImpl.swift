import SwiftyVK

#if os(OSX)
  import Cocoa
#endif
#if os(iOS)
  import UIKit
#endif



class VKDelegateImpl : VKDelegate {
  let appID = "4994842"
  let scope = [VK.Scope.messages,.offline,.friends,.wall,.photos,.audio,.video,.docs,.market,.email]
  let window : AnyObject
  
  
  
  init(window_: AnyObject) {
    VK.defaults.allowLogToConsole = true
    window = window_
    VK.start(appID: appID, delegate: self)
  }
  
  
  
  func vkAutorizationFailed(_ error: VK.Error) {
    print("Autorization failed with error: \n\(error)")
  }
  
  
  
  func vkWillauthorize() -> [VK.Scope] {
    return scope
  }
  
  
  
  func vkDidAuthorize(_ parameters: Dictionary<String, String>) {}
  
  
  
  func vkDidUnauthorize() {}
  
  
  
  func vkTokenPath() -> (useUserDefaults: Bool, alternativePath: String) {
    return (true, "")
  }
  
  
  
  #if os(OSX)
  func vkWillPresentWindow() -> (isSheet: Bool, inWindow: NSWindow?) {
    return (true, window as? NSWindow)
  }
  #endif
  
  
  
  #if os(iOS)
  func vkWillPresentView() -> UIViewController {
    return (self.window as! UIWindow).rootViewController!
  }
  #endif
}
