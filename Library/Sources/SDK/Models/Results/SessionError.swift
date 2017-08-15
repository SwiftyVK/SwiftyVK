import Foundation

public enum SessionError {
    case unknown(Error)
    case tokenNotSavedInStorage
    case vkDelegateNotFound
    case cantParseTokenInfo(String)
    case cantDestroyDefaultSession
    case sessionAlreadyDestroyed(Session)
    case sessionAlreadyAuthorized(Session)
    case cantBuildWebViewUrl(String)
    case cantBuildVkAppUrl(String)
    case cantMakeWebController
    case cantMakeCaptchaController
    case captchaPresenterTimedOut
    case webPresenterTimedOut
    case cantLoadCaptchaImage
    case webPresenterResultIsNil
    case authorizationUrlIsNil
    case authorizationDenied
    case authorizationCancelled
    case authorizationFailed
    
    var asVk: VkError {
        return .session(self)
    }
}
