import Foundation

public enum SessionError: Error {
    case unknown(Error)
    
    
    func toError() -> VkError {
        return .session(self)
    }
}
