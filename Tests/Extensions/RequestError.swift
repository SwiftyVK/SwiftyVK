@testable import SwiftyVK

extension RequestError: Equatable {
    public static func ==(lhs: RequestError, rhs: RequestError) -> Bool {
        switch (lhs, rhs) {
        case
        (.unexpectedResponse, .unexpectedResponse),
        (.jsonNotParsed, .jsonNotParsed),
        (.urlRequestError, .urlRequestError),
        (.unknown, .unknown),
        (.maximumAttemptsExceeded, .maximumAttemptsExceeded),
        (.wrongAttemptType, .wrongAttemptType),
        (.wrongTaskType, .wrongTaskType),
        (.captchaResultIsNil, .captchaResultIsNil),
        (.wrongUrl, .wrongUrl):
            return true
        default:
            return false
        }
    }
}
