import Foundation
#if os(iOS)
    import UIKit
    public typealias Displayer = UIWindow
#elseif os(OSX)
    import Cocoa
    public typealias Displayer = NSWindow
#endif

public final class SessionCallbacks {
    static let `default` = SessionCallbacks()
    
    let onNeedLogin: (() -> Set<VK.Scope>)
    let onLoginSuccess: (([String : String]) -> ())?
    let onLoginFail: ((SessionError) -> ())?
    let onLogout: (() -> ())?
    let onNeedWindow: (() -> Displayer)?
    
    init(
        onNeedLogin: @escaping (() -> Set<VK.Scope>) = { return [] },
        onLoginSuccess: (([String : String]) -> ())? = nil,
        onLoginFail: ((SessionError) -> ())? = nil,
        onLogout: (() -> ())? = nil,
        onNeedWindow: (() -> Displayer)? = nil
        ) {
        self.onNeedLogin = onNeedLogin
        self.onLoginSuccess = onLoginSuccess
        self.onLoginFail = onLoginFail
        self.onLogout = onLogout
        self.onNeedWindow = onNeedWindow
    }
}
