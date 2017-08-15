@testable import SwiftyVK

extension SessionError: Equatable {
    public static func ==(lhs: SessionError, rhs: SessionError) -> Bool {
        switch (lhs, rhs) {
        case
        (.unknown, .unknown),
        (.tokenNotSavedInStorage, .tokenNotSavedInStorage),
        (.vkDelegateNotFound, .vkDelegateNotFound),
        (.cantParseTokenInfo, .cantParseTokenInfo),
        (.cantDestroyDefaultSession, .cantDestroyDefaultSession),
        (.sessionAlreadyDestroyed, .sessionAlreadyDestroyed),
        (.sessionAlreadyAuthorized, .sessionAlreadyAuthorized),
        (.cantBuildWebViewUrl, .cantBuildWebViewUrl),
        (.cantBuildVkAppUrl, .cantBuildVkAppUrl),
        (.cantMakeWebController, .cantMakeWebController),
        (.cantMakeCaptchaController, .cantMakeCaptchaController),
        (.captchaPresenterTimedOut, .captchaPresenterTimedOut),
        (.webPresenterTimedOut, .webPresenterTimedOut),
        (.cantLoadCaptchaImage, .cantLoadCaptchaImage),
        (.webPresenterResultIsNil, .webPresenterResultIsNil),
        (.authorizationUrlIsNil, .authorizationUrlIsNil),
        (.authorizationDenied, .authorizationDenied),
        (.authorizationCancelled, .authorizationCancelled),
        (.authorizationFailed, .authorizationFailed):
            return true
        default:
            return false
        }
    }
}
