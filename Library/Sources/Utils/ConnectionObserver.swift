import Foundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

internal final class ConnectionObserver: NSObject {
    
    private var connected = true
    private let onConnect: () -> ()
    private let onDisconnect: () -> ()
    
    private override init() {
        fatalError("Do not use init()")
    }
    
    init(
        onConnect: @escaping () -> (),
        onDisconnect: @escaping () -> ()
        ) {
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        
        super.init()
        
        #if os(OSX)
            NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(disconnect), name: NSWorkspace.screensDidSleepNotification, object: nil)
            NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(connect), name: NSWorkspace.screensDidWakeNotification, object: nil)
        #elseif os(iOS)
            NotificationCenter.default.addObserver(self, selector: #selector(disconnect), name: .UIApplicationWillResignActive, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(connect), name: .UIApplicationDidBecomeActive, object: nil)
        #endif
        
        let reachability = Reachability()
        NotificationCenter.default.addObserver(self, selector: #selector(onReachabilityChange), name: ReachabilityChangedNotification, object: nil)
        _ = try? reachability?.startNotifier()
        
        VK.Log.put("Connection", "Start observing")
    }
    
    @objc
    private func onReachabilityChange(notification: NSNotification) {
        guard let reachability = notification.object as? Reachability else { return }
        
        if reachability.isReachable {
            onConnect()
        }
        else {
            onDisconnect()
        }
    }
    
    @objc
    private func connect() {
        if connected == false {
            connected = true
            onConnect()
            VK.Log.put("Connection", "restored")
        }
    }
    
    @objc
    private func disconnect() {
        if connected == true {
            connected = false
            onDisconnect()
            VK.Log.put("Connection", "lost")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        VK.Log.put("Connection", "Stop observing")
    }
}
