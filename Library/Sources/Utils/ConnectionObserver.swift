import Foundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

protocol ConnectionObserver {
    func subscribe(object: AnyObject, onUpdate: ConnectionUpdate)
    func unsubscribe(object: AnyObject)
}

typealias ConnectionUpdate = (onConnect: () -> (), onDisconnect: () -> ())

internal final class ConnectionObserverImpl: ConnectionObserver {
    
    private let appStateCenter: VKNotificationCenter
    private let reachabilityCenter: VKNotificationCenter
    private let reachability: VKReachability
    
    private let activeNotificationName: Notification.Name
    private let inactiveNotificationName: Notification.Name
    private let reachabilityNotificationName: Notification.Name
    
    private var appIsActive = true
    
    private var cocoaObservers = [NSObjectProtocol?]()
    private var observers = [ObjectIdentifier: ConnectionUpdate]()
    
    init(
        appStateCenter: VKNotificationCenter,
        reachabilityCenter: VKNotificationCenter,
        reachability: VKReachability,
        activeNotificationName: Notification.Name,
        inactiveNotificationName: Notification.Name,
        reachabilityNotificationName: Notification.Name
        ) {
        self.appStateCenter = appStateCenter
        self.reachabilityCenter = reachabilityCenter
        self.reachability = reachability
        self.activeNotificationName = activeNotificationName
        self.inactiveNotificationName = inactiveNotificationName
        self.reachabilityNotificationName = reachabilityNotificationName
    }
    
    func subscribe(object: AnyObject, onUpdate: ConnectionUpdate) {
        let objectIdentifier = ObjectIdentifier(object)
        observers[objectIdentifier] = onUpdate
        
        setUpAppStateObservers()
        setUpReachabilityObserver()
    }
    
    func unsubscribe(object: AnyObject) {
        let objectIdentifier = ObjectIdentifier(object)
        observers[objectIdentifier] = nil
    }
    
    private func setUpAppStateObservers() {
        let becomeActiveObserver = appStateCenter.addObserver(
            forName: activeNotificationName,
            object: self,
            queue: nil,
            using: { [weak self] _ in
                self?.handleAppActive()
            }
        )
        
        let resignActiveObserver = appStateCenter.addObserver(
            forName: inactiveNotificationName,
            object: self,
            queue: nil,
            using: { [weak self] _ in
                self?.handleAppInnactive()
            }
        )
        
        cocoaObservers.append(contentsOf: [becomeActiveObserver, resignActiveObserver])
    }
    
    private func setUpReachabilityObserver() {
        let reachabilityObserver = appStateCenter.addObserver(
            forName: reachabilityNotificationName,
            object: self,
            queue: nil,
            using: { [weak self] _ in
                self?.handleReachabilityChange()
            }
        )
        
        cocoaObservers.append(reachabilityObserver)
        _ = try? reachability.startNotifier()
    }
    
    private func handleReachabilityChange() {
        guard appIsActive == true else { return }

        if reachability.isReachable {
            observers.forEach { $0.value.onConnect() }
        }
        else {
            observers.forEach { $0.value.onDisconnect() }
        }
    }
    
    private func handleAppActive() {
        guard appIsActive == false else { return }
        appIsActive = true
        observers.forEach { $0.value.onConnect() }
    }
    
    private func handleAppInnactive() {
        guard appIsActive == true else { return }
        appIsActive = false
        observers.forEach { $0.value.onDisconnect() }
    }
    
    deinit {
        for observer in cocoaObservers {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
