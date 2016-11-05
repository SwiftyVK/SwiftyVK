#if os(OSX)
    import Foundation
#endif
#if os(iOS)
    import UIKit
#endif



private let redirectUrl = "https://oauth.vk.com/blank.html"
private let webAuthorizeUrl = "https://oauth.vk.com/authorize?"
private let appAuthorizeUrl = "vkauthorize://authorize?"



internal struct Authorizator {
    
    
    
    fileprivate static var paramsUrl : String {
        let _perm = VK.Scope.toInt(VK.delegate!.vkWillAuthorize())
        let _redir = canAuthorizeWithVkApp ? "" : "&redirect_uri=\(redirectUrl)"
        
        return  "client_id=\(VK.appID!)&scope=\(_perm)&display=mobile&v\(VK.config.apiVersion)&sdk_version=\(VK.config.sdkVersion)\(_redir)&response_type=token&revoke=\(Token.revoke ? 1 : 0)"
    }
    
    private static var error: AuthError?
    
    
    
    internal static func authorize() -> AuthError? {
        error = nil

        guard Token.get() == nil else {return nil}
        
        Thread.isMainThread
            ? sheetQueue.async(execute: start)
            : sheetQueue.sync(execute: start)
        
        return error
    }
    
    
    
    internal static func validate(withUrl url: String) -> AuthError? {
        error = nil
        
        Thread.isMainThread
            ? sheetQueue.async {
                error = WebPresenter.start(withUrl: url)
                }
            : sheetQueue.sync {
                error = WebPresenter.start(withUrl: url)
        }
        
        return error
    }
    
    
    
    private static func start() {
        if canAuthorizeWithVkApp {
            startWithApp()
        }
        else {
            startWithWeb()
        }
        
        if VK.state != .authorized {
            if error == nil {
                error = AuthError.deniedFromUser
            }
            
            DispatchQueue.global(qos: .default).async {
                VK.delegate?.vkAutorizationFailedWith(error: error!)
            }
        }
    }
    
    
    
    fileprivate static func startWithWeb() {
        error = WebPresenter.start(withUrl: webAuthorizeUrl+paramsUrl)
    }
}
//
//
//
//
//
//
//
//
//
//
//
#if os(iOS)
    private typealias IOSAuthorizator = Authorizator
    extension IOSAuthorizator {
        
        
        
        internal static var canAuthorizeWithVkApp : Bool {
            return UIApplication.shared.canOpenURL(URL(string: "vk\(VK.appID!)://")!)
        }
        
        
        
        fileprivate static func startWithApp() {
            UIApplication.shared.openURL(URL(string: appAuthorizeUrl+paramsUrl)!)
            Thread.sleep(forTimeInterval: 1)
            startWithWeb()
        }
        
        
        
        internal static func recieveTokenURL(url: URL, fromApp app: String?) {
            if (app == "com.vk.vkclient" || app == "com.vk.vkhd" || url.scheme == "vk\(VK.appID!)") {
                if url.absoluteString.contains("access_token=") {
                    _ = Token(urlString: url.absoluteString)
                    WebPresenter.cancel()
                }
            }
        }
    }
#endif
//
//
//
//
//
//
//
//
//
//
//
#if os(OSX)
    private typealias OSXAuthorizator = Authorizator
    extension OSXAuthorizator {
        internal static var canAuthorizeWithVkApp : Bool {return false}
        fileprivate static func startWithApp() {}
    }
#endif
