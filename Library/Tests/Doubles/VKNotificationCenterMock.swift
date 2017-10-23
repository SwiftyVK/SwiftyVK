@testable import SwiftyVK
import XCTest

typealias ObserverBlock = (Notification) -> Void

final class VKNotificationCenterMock: VKNotificationCenter {
    private(set) var blocks = [NSNotification.Name: ObserverBlock]()
    
    var onAddObserver: ((NSNotification.Name?) -> ())?
    
    func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        guard let name = name else { return NSString() }
        
        onAddObserver?(name)
        blocks[name] = block
        return name.rawValue as NSString
    }
    
    var onRemoveObserver: ((String) -> ())?
    
    func removeObserver(_ observer: Any) {
        guard let name = observer as? String else { return }
        blocks.removeValue(forKey: Notification.Name(name))
        onRemoveObserver?(name)
    }
    
}
