#if os(macOS)
    import Cocoa
    /// Multiplatform ViewController
    public typealias VKViewController = NSViewController
#elseif os(iOS)
    import UIKit
    /// Multiplatform ViewController
    public typealias VKViewController = UIViewController
#endif

protocol DismisableController: AnyObject {
    var onDismiss: (() -> ())? { get set }
}
