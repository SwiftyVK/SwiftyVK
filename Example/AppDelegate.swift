import SwiftyVK



var vkDelegateReference : SwiftyVKDelegate?


#if os(iOS)
    import UIKit
    
    
    
    @UIApplicationMain
    final class AppDelegate : UIResponder, UIApplicationDelegate {
        var window: UIWindow?
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
            vkDelegateReference = VKDelegateExample()
            return true
        }
        
        
        
        
        @available(iOS 9.0, *)
        func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
            let app = options[.sourceApplication] as? String
            VK.process(url: url, sourceApplication: app)
            return true
        }
        
        
        
        func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            VK.process(url: url, sourceApplication: sourceApplication)
            return true
        }
    }
    
    
    
#elseif os(OSX)
    import Cocoa
    
    
    
    @NSApplicationMain
    final class AppDelegate : NSObject, NSApplicationDelegate {
        
        func applicationDidFinishLaunching(_ aNotification: Notification) {
            vkDelegateReference = VKDelegateExample()
        }
    }
#endif
