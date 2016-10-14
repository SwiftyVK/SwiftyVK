import SwiftyVK

#if os(OSX)
    import Cocoa
#endif
#if os(iOS)
    import UIKit
#endif



class VKDelegateExample: VKDelegate {
    let appID = "4994842"
    let scope = [VK.Scope.messages,.offline,.friends,.wall,.photos,.audio,.video,.docs,.market,.email]
    
    
    
    init() {
        VK.configure(appID: appID, delegate: self)
    }
    
    
    
    func vkWillAuthorize() -> [VK.Scope] {
        return scope
    }
    
    
    
    func vkDidAuthorizeWith(parameters: Dictionary<String, String>) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TestVkDidAuthorize"), object: nil)
    }
    
    
    
    
    func vkAutorizationFailedWith(error: ErrorAuth) {
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
