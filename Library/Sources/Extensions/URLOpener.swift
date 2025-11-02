#if os(macOS)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

protocol URLOpener {
    func canOpenURL(_ url: URL) -> Bool
    func openURL(_ url: URL) -> Bool
}

#if os(macOS)
    final class URLOpenerMacOS: URLOpener {
        
        func canOpenURL(_ url: URL) -> Bool {
            return false
        }
        
        func openURL(_ url: URL) -> Bool {
            return NSWorkspace.shared.open(url)
        }
    }
#elseif os(iOS)
final class URLOpenerIOS: URLOpener {
    func canOpenURL(_ url: URL) -> Bool {
        UIApplication.shared.canOpenURL(url)
    }

    func openURL(_ url: URL) -> Bool {
        UIApplication.shared.open(url)
        return true
    }
}
#endif
