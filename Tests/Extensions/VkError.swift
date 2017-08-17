@testable import SwiftyVK

extension VkError: Equatable {
    public static func ==(lhs: VkError, rhs: VkError) -> Bool {
        switch (lhs, rhs) {
        case let (api(first), api(second)):
            return first == second
        case
        (.unexpectedResponse, .unexpectedResponse),
        (.jsonNotParsed, .jsonNotParsed),
        (.urlRequestError, .urlRequestError),
        (.unknown, .unknown),
        (.maximumAttemptsExceeded, .maximumAttemptsExceeded),
        (.wrongAttemptType, .wrongAttemptType),
        (.wrongTaskType, .wrongTaskType),
        (.captchaResultIsNil, .captchaResultIsNil),
        (.wrongUrl, .wrongUrl),
        (.tokenNotSavedInStorage, .tokenNotSavedInStorage),
        (.cantMakeCapthaImageUrl, .cantMakeCapthaImageUrl),
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
        case (_, _):
            return false
        }
    }
}

extension Error {
    var asVk: VkError? {
        return self as? VkError
    }
}
