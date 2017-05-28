#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

protocol UrlOpener {
    func canOpenURL(_ url: URL) -> Bool
    func openURL(_ url: URL) -> Bool
}

#if os(OSX)
    final class MacOsApplication: UrlOpener {
        func canOpenURL(_ url: URL) -> Bool {
            return false
        }
        
        func openURL(_ url: URL) -> Bool {
            return NSWorkspace.shared().open(url)
        }
    }
#elseif os(iOS)
    extension UIApplication: UrlOpener {}
#endif
