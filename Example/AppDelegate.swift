import Foundation
import SwiftyVK

private let appId = "4994842"
private func setUpVK() -> Swift.Task<Void, Never> {
    let scopes: Scopes = [.messages, .offline, .friends, .wall, .photos, .audio, .video, .docs, .market, .email]
    let tokenEvents = VKTokenEventsStream()

    VK.setUp(
        appId: appId,
        scopeProvider: { _ in scopes },
        onViewNeedsToPresent: { viewController in
            DispatchQueue.main.async {
                present(viewController)
            }
        },
        tokenEvents: .stream(tokenEvents)
    )

    return Swift.Task {
        for await event in tokenEvents.stream {
            print("SwiftyVK: token event \(event)")
        }
    }
}

@MainActor
private func present(_ viewController: VKViewController) {
    #if os(macOS)
        NSApplication.shared.keyWindow?.contentViewController?.presentAsSheet(viewController)
    #elseif os(iOS)
        UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true)
    #endif
}


#if os(iOS)
    import UIKit
    
    @UIApplicationMain
    final class AppDelegate : UIResponder, UIApplicationDelegate {
        var window: UIWindow?
        private var tokenEventsTask: Swift.Task<Void, Never>?
        
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
        ) -> Bool {
            tokenEventsTask = setUpVK()
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
        private var tokenEventsTask: Swift.Task<Void, Never>?
        
        func applicationDidFinishLaunching(_ aNotification: Notification) {
            tokenEventsTask = setUpVK()
        }
    }
#endif
