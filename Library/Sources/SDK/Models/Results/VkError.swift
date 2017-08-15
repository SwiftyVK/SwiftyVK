import Foundation

public enum VkError: Error {
    case api(ApiError)
    case request(RequestError)
    case session(SessionError)
    
    func toApi() -> ApiError? {
        switch self {
        case let .api(error):
            return error
        default:
            return nil
        }
    }
}
