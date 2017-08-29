@testable import SwiftyVK
import XCTest

typealias ObserverBlock = (Notification) -> Void

class VKNotificationCenterMock: VKNotificationCenter {
    private(set) var blocks = [String: ObserverBlock]()
    
    
    func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        guard let name = name?.rawValue else {
            return NSString()
        }
        
        blocks[name] = block
        return name as NSString
    }
    
    func removeObserver(_ observer: Any) {
        guard let name = observer as? String else { return }
        blocks.removeValue(forKey: name)
    }
    
}
