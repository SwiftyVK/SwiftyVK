import Foundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

internal final class ConnectionObserver {
    
    private let defaultCenter: VKNotificationCenter?
    private let workspaceCenter: VKNotificationCenter?
    private let reachability: VKReachability
    
    private var appIsActive = true
    private var onConnect: (() -> ())?
    private var onDisconnect: (() -> ())?
    
    private var observers = [NSObjectProtocol?]()
    
    init(
        defaultCenter: VKNotificationCenter?,
        workspaceCenter: VKNotificationCenter?,
        reachability: VKReachability
        ) {
        self.defaultCenter = defaultCenter
        self.workspaceCenter = workspaceCenter
        self.reachability = reachability
    }
    
    public func setUp(
        onConnect: @escaping () -> (),
        onDisconnect: @escaping () -> ()
        ) {
        
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        
        #if os(OSX)
            setUpMacOsObservers()
        #elseif os(iOS)
            setUpIosObservers()
        #endif
        
        setUpReachabilityObserver()
    }
    
    @available(macOS 10.0, *)
    private func setUpMacOsObservers() {
        let becomeActiveObserver = workspaceCenter?.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: self,
            queue: nil,
            using: { [weak self] notification in
                self?.handleAppActive(notification)
            }
        )
        
        let resignActiveObserver = workspaceCenter?.addObserver(
            forName: NSWorkspace.screensDidSleepNotification,
            object: self,
            queue: nil,
            using: { [weak self] notification in
                self?.handleAppInnactive(notification)
            }
        )
        
        observers.append(contentsOf: [becomeActiveObserver, resignActiveObserver])
    }
    
    @available(iOS 1.0, *)
    private func setUpIosObservers() {
        let becomeActiveObserver = defaultCenter?.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: self,
            queue: nil,
            using: { [weak self] notification in
                self?.handleAppActive(notification)
            }
        )
        
        let resignActiveObserver = defaultCenter?.addObserver(
            forName: NSWorkspace.screensDidSleepNotification,
            object: self,
            queue: nil,
            using: { [weak self] notification in
                self?.handleAppInnactive(notification)
            }
        )
        
        observers.append(contentsOf: [becomeActiveObserver, resignActiveObserver])
    }
    
    private func setUpReachabilityObserver() {
        
        let reachabilityObserver = defaultCenter?.addObserver(
            forName: ReachabilityChangedNotification,
            object: self,
            queue: nil,
            using: { [weak self] notification in
                self?.handleReachabilityChange(notification)
            }
        )
        
        observers.append(reachabilityObserver)
        
        _ = try? reachability.startNotifier()
    }
    
    private func handleReachabilityChange(_ notification: Notification) {
        guard let reachability = notification.object as? VKReachability else { return }
        guard appIsActive == true else { return }

        if reachability.isReachable {
            onConnect?()
        }
        else {
            onDisconnect?()
        }
    }
    
    private func handleAppActive(_ notification: Notification) {
        guard appIsActive == false else { return }
        appIsActive = true
        onConnect?()
    }
    
    private func handleAppInnactive(_ notification: Notification) {
        guard appIsActive == true else { return }
        appIsActive = false
        onDisconnect?()
    }
    
    deinit {
        for observer in observers {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
