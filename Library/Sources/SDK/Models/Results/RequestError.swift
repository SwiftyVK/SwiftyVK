import Foundation

public enum RequestError {
    case unexpectedResponse
    case jsonNotParsed(Error)
    case urlRequestError(Error)
    case unknown(Error)
    case maximumAttemptsExceeded
    case wrongAttemptType
    case wrongTaskType
    case captchaResultIsNil
    case wrongUrl
    
    func toError() -> VkError {
        return .request(self)
    }
}
