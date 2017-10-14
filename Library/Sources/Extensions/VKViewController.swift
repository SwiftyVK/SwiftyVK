#if os(macOS)
    import Cocoa
    public typealias VKViewController = NSViewController
#elseif os(iOS)
    import UIKit
    public typealias VKViewController = UIViewController
#endif
