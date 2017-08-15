import Foundation

public enum RequestError: Error {
    case unexpectedResponse
    case jsonNotParsed(Error)
    case urlRequestError(Error)
    case unknown(Error)
    case maximumAttemptsExceeded
    
    func toError() -> VkError {
        return .request(self)
    }
}
