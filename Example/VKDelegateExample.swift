import SwiftyVK

#if os(OSX)
    import Cocoa
#endif
#if os(iOS)
    import UIKit
#endif



class VKDelegateExample: VKDelegate {
    let appID = "4994842"
    let scope: Set<VK.Scope> = [.messages,.offline,.friends,.wall,.photos,.audio,.video,.docs,.market,.email]
    
    
    
    init() {
        VK.config.logToConsole = true
        VK.configure(withAppId: appID, delegate: self)
    }
    
    
    
    func vkWillAuthorize() -> Set<VK.Scope> {
        return scope
    }
    
    
    
    func vkDidAuthorizeWith(parameters: Dictionary<String, String>) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TestVkDidAuthorize"), object: nil)
    }
    
    
    
    
    func vkAutorizationFailedWith(error: AuthError) {
        print("Autorization failed with error: \n\(error)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TestVkDidNotAuthorize"), object: nil)
    }
    
    
    
    func vkDidUnauthorize() {}
    
    
    
    func vkShouldUseTokenPath() -> String? {
        return nil
    }
    
    
    
    #if os(OSX)
    func vkWillPresentView() -> NSWindow? {
        return NSApplication.shared().windows[0]
    }
    #endif
    
    
    
    #if os(iOS)
    func vkWillPresentView() -> UIViewController {
        return UIApplication.shared.delegate!.window!!.rootViewController!
    }
    #endif
}
