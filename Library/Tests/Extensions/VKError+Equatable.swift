@testable import SwiftyVK

extension VKError: Equatable {
    public static func ==(lhs: VKError, rhs: VKError) -> Bool {
        switch (lhs, rhs) {
        case let (api(first), api(second)):
            return first == second
        case
        (.unexpectedResponse, .unexpectedResponse),
        (.jsonNotParsed, .jsonNotParsed),
        (.urlRequestError, .urlRequestError),
        (.unknown, .unknown),
        (.captchaResultIsNil, .captchaResultIsNil),
        (.wrongUrl, .wrongUrl),
        (.cantSaveToKeychain, .cantSaveToKeychain),
        (.cantMakeCapthaImageUrl, .cantMakeCapthaImageUrl),
        (.vkDelegateNotFound, .vkDelegateNotFound),
        (.cantParseTokenInfo, .cantParseTokenInfo),
        (.sessionAlreadyDestroyed, .sessionAlreadyDestroyed),
        (.sessionAlreadyAuthorized, .sessionAlreadyAuthorized),
        (.cantBuildWebViewUrl, .cantBuildWebViewUrl),
        (.cantBuildVKAppUrl, .cantBuildVKAppUrl),
        (.cantMakeWebController, .cantMakeWebController),
        (.cantMakeCaptchaController, .cantMakeCaptchaController),
        (.captchaPresenterTimedOut, .captchaPresenterTimedOut),
        (.webPresenterTimedOut, .webPresenterTimedOut),
        (.cantLoadCaptchaImage, .cantLoadCaptchaImage),
        (.webPresenterResultIsNil, .webPresenterResultIsNil),
        (.authorizationUrlIsNil, .authorizationUrlIsNil),
        (.authorizationDenied, .authorizationDenied),
        (.authorizationCancelled, .authorizationCancelled),
        (.authorizationFailed, .authorizationFailed),
        (.needAuthorization, .needAuthorization),
        (.captchaWasDismissed, .captchaWasDismissed):
            return true
        case (_, _):
            return false
        }
    }
}

extension Error {
    var asVK: VKError? {
        return self as? VKError
    }
}
