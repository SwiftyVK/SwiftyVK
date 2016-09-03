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
        VK.defaults.logToConsole = true
        window = window_
        VK.configure(appID: appID, delegate: self)
    }
    
    
    
    func vkAutorizationFailedWith(error: VK.Error) {
        print("Autorization failed with error: \n\(error)")
    }
    
    
    
    func vkWillAuthorize() -> [VK.Scope] {
        return scope
    }
    
    
    
    func vkDidAuthorizeWith(parameters: Dictionary<String, String>) {}
    
    
    
    func vkDidUnauthorize() {}
    
    
    
    func vkShouldUseTokenPath() -> String? {
        return nil
    }
    
    
    
    #if os(OSX)
    func vkWillPresentView() -> NSWindow? {
        return window as? NSWindow
    }
    #endif
    
    
    
    #if os(iOS)
    func vkWillPresentView() -> UIViewController {
        return (self.window as! UIWindow).rootViewController!
    }
    #endif
}
