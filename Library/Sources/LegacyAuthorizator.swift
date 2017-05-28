#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

private let redirectUrl = "https://oauth.vk.com/blank.html"
private let webAuthorizeUrl = "https://oauth.vk.com/authorize?"
private let appAuthorizeUrl = "vkauthorize://authorize?"

struct LegacyAuthorizator {

    fileprivate static var paramsUrl: String? {
        guard let appId = VK.appId, let delegate = VK.legacyDelegate else {
            return nil
        }
        
        let _perm = delegate.vkWillAuthorize().toInt()
        let _redir = canAuthorizeWithVkApp ? "" : "&redirect_uri=\(redirectUrl)"

        return  "client_id=\(appId)&scope=\(_perm)&display=mobile&v\(SessionConfig.apiVersion)&sdk_version=\(SessionConfig.sdkVersion)\(_redir)&response_type=token&revoke=\(LegacyToken.revoke ? 1 : 0)"
    }

    fileprivate static var error: SessionError?

    static func authorize() -> SessionError? {
        error = nil

        guard LegacyToken.get() == nil else {return nil}

        Thread.isMainThread
            ? sheetQueue.async(execute: start)
            : sheetQueue.sync(execute: start)

        return error
    }
    
    static func authorizeWith(rawToken: String, expiresIn: Int) {
        _ = LegacyToken(fromRawToken: rawToken, expiresIn: expiresIn)
    }

    static func validate(withUrl url: String) -> SessionError? {
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
                VK.legacyDelegate?.vkAutorizationFailedWith(error: _error)
            }
        }
    }

    fileprivate static func startWithWeb() {
        guard let paramsUrl = paramsUrl else {
            error = .notConfigured
            return
        }
        
        error = WebPresenter.start(withUrl: webAuthorizeUrl + paramsUrl)
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
    private typealias IOSAuthorizator = LegacyAuthorizator
    extension IOSAuthorizator {

        static var canAuthorizeWithVkApp: Bool {
            guard let appId = VK.appId, let url = URL(string: "vk\(appId)://") else {
                return false
            }
            
            return UIApplication.shared.canOpenURL(url)
        }

        fileprivate static func startWithApp() {
            guard let paramsUrl = paramsUrl, let url = URL(string: appAuthorizeUrl + paramsUrl) else {
                return
            }
            
            UIApplication.shared.openURL(url)
            Thread.sleep(forTimeInterval: 1)
            startWithWeb()
        }

        static func recieveTokenURL(url: URL, fromApp app: String?) {
            guard let appId = VK.appId else {
                return
            }
            
            if app == "com.vk.vkclient" || app == "com.vk.vkhd" || url.scheme == "vk\(appId)" {
                if url.absoluteString.contains("access_token=") {
                    _ = LegacyToken(fromResponse: url.absoluteString)
                    WebPresenter.cancel()
                }
            }
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
#elseif os(OSX)
    private typealias OSXAuthorizator = LegacyAuthorizator
    extension OSXAuthorizator {
        static var canAuthorizeWithVkApp: Bool {return false}
        fileprivate static func startWithApp() {}
    }
#endif
