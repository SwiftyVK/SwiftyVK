import Foundation

public enum SessionError {
    case unknown(Error)
    
    
    func toError() -> VkError {
        return .session(self)
    }
}
