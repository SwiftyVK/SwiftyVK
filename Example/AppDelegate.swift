import SwiftyVK



var vkDelegateReference : SwiftyVKDelegate?


#if os(iOS)
    import UIKit
    
    @UIApplicationMain
    final class AppDelegate : UIResponder, UIApplicationDelegate {
        var window: UIWindow?
        
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
        ) -> Bool {
            vkDelegateReference = VKDelegateExample()
            return true
        }
        
        func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey: Any] = [:]
        ) -> Bool {
            let app = options[.sourceApplication] as? String
            VK.handle(url: url, sourceApplication: app)
            return true
        }
    }
#elseif os(macOS)
    import Cocoa
    
    @NSApplicationMain
    final class AppDelegate : NSObject, NSApplicationDelegate {
        
        func applicationDidFinishLaunching(_ aNotification: Notification) {
            vkDelegateReference = VKDelegateExample()
        }
    }
#endif
