#if os(iOS)
    import UIKit
    public typealias VKViewController = UIViewController
#elseif os(OSX)
    import Cocoa
    public typealias VKViewController = NSViewController
#endif
