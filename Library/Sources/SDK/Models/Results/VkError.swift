import Foundation

public enum VkError<ParserError: Error>: Error {
    case api(ApiError)
    case request(RequestError)
    case session(SessionError)
    case custom(ParserError)
}
