import Foundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

internal final class ConnectionObserver: NSObject {
    
    private let reachability: Reachability
    
    private let onConnect: () -> ()
    private let onDisconnect: () -> ()
    private var isInForeground = true
    
    private override init() {
        fatalError()
    }
    
    init?(
        onConnect: @escaping () -> (),
        onDisconnect: @escaping () -> ()
        ) {
        guard let reachability = Reachability() else { return nil }
        self.reachability = reachability
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        
        super.init()
        
        #if os(OSX)
            NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(onBackground), name: .NSWorkspaceWillSleep, object: nil)
            NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(onForeground), name: .NSWorkspaceDidWake, object: nil)
        #elseif os(iOS)
            NotificationCenter.default.addObserver(self, selector: #selector(onBackground), name: .UIApplicationWillResignActive, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(onForeground), name: .UIApplicationDidBecomeActive, object: nil)
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReachabilityChange), name: ReachabilityChangedNotification, object: nil)
        _ = try? reachability.startNotifier()
        
        VK.Log.put("Connection", "Start observing")
    }
    
    @objc
    private func onReachabilityChange(notification: NSNotification) {
        if reachability.isReachable {
            guard isInForeground else { return }
            connect()
        }
        else {
            guard isInForeground else { return }
            disconnect()
        }
    }
    
    @objc
    private func onForeground() {
        isInForeground = true
        guard reachability.isReachable else { return }
        connect()
    }
    
    @objc
    private func onBackground() {
        isInForeground = false
        guard reachability.isReachable else { return }
        disconnect()
    }
    
    private func connect() {
        if isInForeground && reachability.isReachable {
            onConnect()
            VK.Log.put("Connection", "restored")
        }
    }
    
    private func disconnect() {
        if !isInForeground || !reachability.isReachable {
            onDisconnect()
            VK.Log.put("Connection", "lost")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        VK.Log.put("Connection", "Stop observing")
    }
}
