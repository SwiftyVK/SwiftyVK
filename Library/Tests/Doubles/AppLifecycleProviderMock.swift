@testable import SwiftyVK

final class AppLifecycleProviderMock: AppLifecycleProvider {
    var current: AppState?
    var handlers = [Int: (AppState) -> ()]()
    
    func subscribe(_ object: AnyObject, handler: @escaping (AppState) -> ()) {
        let id = ObjectIdentifier(object).hashValue
        handlers[id] = handler
    }
    
    func unsubscribe(_ object: AnyObject) {
        let id = ObjectIdentifier(object).hashValue
        handlers[id] = nil
    }
    
    func notify(state: AppState) {
        handlers.values.forEach { $0(state) }
    }
}
