protocol AppLifecycleProvider: AnyObject {
    var current: AppState? { get }
    
    func subscribe(_ object: AnyObject, handler: @escaping (AppState) -> ())
    func unsubscribe(_ object: AnyObject)
}

#if os(iOS)
import UIKit

final class IOSAppLifecycleProvider: AppLifecycleProvider {
    var current: AppState?
    
    let observer = ParameterizedObserver<AppState>()

    init() {
        let application = UIApplication.shared

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: application
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: application
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: application
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: application
        )
    }
    
    func subscribe(_ object: AnyObject, handler: @escaping (AppState) -> ()) {
        if let current = current {
            observer.notify(with: current)
        }
        
        observer.subscribe(object, handler: handler)
    }
    
    func unsubscribe(_ object: AnyObject) {
        observer.unsubscribe(object)
    }
    
    @objc
    private func handleDidBecomeActive() {
        current = .active
        observer.notify(with: .active)
    }
    
    @objc
    private func handleWillResignActive() {
        current = .inactive
        observer.notify(with: .inactive)
    }
    
    @objc
    private func handleDidEnterBackground() {
        current = .background
        observer.notify(with: .background)
    }
    
    @objc
    private func handleWillEnterForeground() {
        current = .foreground
        observer.notify(with: .foreground)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
#elseif os(macOS)
final class MacOSAppLifecycleProvider: AppLifecycleProvider {
    var current: AppState?
    
    func subscribe(_ object: AnyObject, handler: @escaping (AppState) -> ()) {}
    func unsubscribe(_ object: AnyObject) {}
}
#endif

enum AppState {
    case active
    case inactive
    case background
    case foreground
}
