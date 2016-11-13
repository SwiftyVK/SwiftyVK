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



    fileprivate static var paramsUrl: String? {
        guard let appId = VK.appID, let delegate = VK.delegate else {
            return nil
        }
        
        let _perm = VK.Scope.toInt(delegate.vkWillAuthorize())
        let _redir = canAuthorizeWithVkApp ? "" : "&redirect_uri=\(redirectUrl)"

        return  "client_id=\(appId)&scope=\(_perm)&display=mobile&v\(VK.config.apiVersion)&sdk_version=\(VK.config.sdkVersion)\(_redir)&response_type=token&revoke=\(Token.revoke ? 1 : 0)"
    }

    fileprivate static var error: AuthError?



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

        if VK.state < .authorized {
            
            let _error = error ?? .deniedFromUser

            DispatchQueue.global(qos: .default).async {
                VK.delegate?.vkAutorizationFailedWith(error: _error)
            }
        }
    }



    fileprivate static func startWithWeb() {
        guard let paramsUrl = paramsUrl else {
            error = .notConfigured
            return
        }
        
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



        internal static var canAuthorizeWithVkApp: Bool {
            guard let appId = VK.appID, let url = URL(string: "vk\(appId)://") else {
                return false
            }
            
            return UIApplication.shared.canOpenURL(url)
        }



        fileprivate static func startWithApp() {
            guard let paramsUrl = paramsUrl, let url = URL(string: appAuthorizeUrl+paramsUrl) else {
                return
            }
            
            UIApplication.shared.openURL(url)
            Thread.sleep(forTimeInterval: 1)
            startWithWeb()
        }



        internal static func recieveTokenURL(url: URL, fromApp app: String?) {
            guard let appId = VK.appID else {
                return
            }
            
            if app == "com.vk.vkclient" || app == "com.vk.vkhd" || url.scheme == "vk\(appId)" {
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
        internal static var canAuthorizeWithVkApp: Bool {return false}
        fileprivate static func startWithApp() {}
    }
#endif
