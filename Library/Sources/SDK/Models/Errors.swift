import Foundation

public enum LegacySessionError: Int, CustomNSError, CustomStringConvertible {
    case nilParentView              = 1
    case deniedFromUser             = 2
    case failedValidation           = 3
    case failedAuthorization        = 4
    case notConfigured              = 5
    case delegateNotFound           = 6
    case cantDestroyDefaultSession  = 7
    case sessionDestroyed           = 8
    case tokenNotSavedInStorage     = 9
    case cantBuildUrlForVkApp       = 10
    case authCalledFromMainThread   = 11
    case webPresenterResultIsNil    = 12
    case wrongAuthUrl               = 13
    case webPresenterTimedOut       = 14
    case cantBuildUrlForWebView     = 15
    case cantMakeWebViewController  = 16
    case cantParseToken             = 17
    case captchaPresenterTimedOut   = 18
    case cantLoadCaptchaImage       = 19
    case alreadyAuthorized          = 20
    case cantMakeCaptchaController  = 21

    public static let errorDomain = "SwiftyVKSessionError"
    public var errorCode: Int {return rawValue}
    public var errorUserInfo: [String : Any] {return [:]}

    public var description: String {
        return String(format: "error %@[%d]: %@", LegacySessionError.errorDomain, errorCode, errorUserInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }
}

extension NSError {
    override open var description: String {
        return String(format: "error %@[%d]: %@", domain, code, userInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }
}
