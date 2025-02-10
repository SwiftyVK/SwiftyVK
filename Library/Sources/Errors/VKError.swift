import Foundation

/// Represents any error which SwiftyVK can return
public indirect enum VKError: Error {
    // MARK: - Any error wrapper
    case unknown(Error)
    
    // MARK: - Errors from VK API
    case api(ApiError)
    
    // MARK: - Session errors
    case cantSaveToKeychain(Int32)
    case vkDelegateNotFound
    case cantParseTokenInfo(String)
    case sessionAlreadyDestroyed(Session)
    case sessionAlreadyAuthorized(Session)
    case sessionIsNotAuthorized(Session)

    // MARK: - Request errors
    case unexpectedResponse
    case jsonNotParsed(Error)
    case urlRequestError(Error)
    case captchaResultIsNil
    case wrongUrl
    case cantAwaitOnMainThread
    case cantAwaitRequestWithSettedCallbacks
    
    // MARK: - UI Errors
    case cantBuildWebViewUrl(String)
    case cantBuildVKAppUrl(String)
    case captchaPresenterTimedOut
    case cantMakeCapthaImageUrl(String)
    case cantLoadCaptchaImage(Error)
    case cantLoadCaptchaImageWithUnknownReason
    case webPresenterTimedOut
    case webPresenterResultIsNil
    case webControllerError(Error)
    case authorizationUrlIsNil
    case authorizationDenied
    case authorizationCancelled
    case authorizationFailed
    case captchaWasDismissed
    case sharingWasDismissed
    case vkAppTokenIsNil
    case weakObjectWasDeallocated
    
    func toApi() -> ApiError? {
        switch self {
        case let .api(error):
            return error
        default:
            return nil
        }
    }
}
