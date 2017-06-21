import SwiftyVK

#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif



class VKDelegateExample: SwiftyVKDelegate {
    
    let appId = "4994842"
    let scopes: Scopes = [.messages,.offline,.friends,.wall,.photos,.audio,.video,.docs,.market,.email]
    
    init() {
        VK.prepareForUse(appId: appId, delegate: self)
    }

    func vkNeedToPresent(viewController: VKViewController) {
        #if os(OSX)
            if let contentController = NSApplication.shared.keyWindow?.contentViewController {
                contentController.presentViewControllerAsSheet(viewController)
            }
        #elseif os(iOS)
            if let rootController = UIApplication.shared.keyWindow?.rootViewController {
                rootController.present(viewController, animated: true, completion: nil)
            }
        #endif
    }
    
    func vkTokenCreated(for sessionId: String, info: [String : String]) {
        print("token created in session \(sessionId) with info \(info)")
    }
    
    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
        print("token updated in session \(sessionId) with info \(info)")
    }
    
    func vkTokenRemoved(for sessionId: String) {
        print("token removed in session \(sessionId)")
    }
    
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        return scopes
    }
    
    func vkDidLogOut(for sessionId: String) {
        print("logout in", sessionId)
    }
}
