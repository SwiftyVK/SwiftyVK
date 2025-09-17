import Foundation

enum VKDomains {
    // Root and scheme
    static let root = "vk.ru"
    static let scheme = "https"

    // Host builder
    static func host(_ sub: String? = nil) -> String {
        if let sub = sub, !sub.isEmpty { return "\(sub).\(root)" }
        return root
    }

    // Core hosts
    static var siteHost: String { host() }
    static var mSiteHost: String { host("m") }
    static var oauthHost: String { host("oauth") }
    static var apiHost: String { host("api") }

    // Base URLs
    static var apiMethodBase: String { "\(scheme)://\(apiHost)/method/" }
    static var oauthAuthorizeUrl: String { "\(scheme)://\(oauthHost)/authorize?" }
    static var oauthRedirectUrl: String { "\(scheme)://\(oauthHost)/blank.html" }

    // Convenience
    static var allowedAuthHosts: Set<String> { [siteHost, mSiteHost, oauthHost] }
}
