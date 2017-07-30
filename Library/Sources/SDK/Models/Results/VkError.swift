import Foundation

public enum VkError: Error {
    case api(ApiError)
    case request(RequestError)
    case session(SessionError)
}
