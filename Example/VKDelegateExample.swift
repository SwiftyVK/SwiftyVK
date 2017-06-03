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

    func vkNeedToPresent(viewController: VkViewController) {
        #if os(OSX)
            if let contentController = NSApplication.shared().keyWindow?.contentViewController {
                contentController.presentViewControllerAsSheet(viewController)
            }
        #elseif os(iOS)
            if let rootController = UIApplication.shared.keyWindow?.rootViewController {
                viewController.modalPresentationStyle = .overFullScreen
                viewController.modalTransitionStyle = .crossDissolve
                rootController.present(viewController, animated: true, completion: nil)
            }
        #endif
    }
    
    func vkWillLogIn(in session: Session) -> Scopes {
        return scopes
    }
    
    func vkDidLogOut(in session: Session) {
        print("logout in", session.id)
    }
}
