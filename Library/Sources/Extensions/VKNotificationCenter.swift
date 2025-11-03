import Foundation

protocol VKNotificationCenter {
    func addObserver(
        forName name: NSNotification.Name?,
        object obj: Any?,
        queue: OperationQueue?,
        using block: @escaping @Sendable (Notification) -> Swift.Void)
        -> NSObjectProtocol
    
    func removeObserver(_ observer: Any)
}

extension NotificationCenter: VKNotificationCenter {}

