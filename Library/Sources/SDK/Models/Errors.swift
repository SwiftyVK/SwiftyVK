import Foundation

extension NSError {
    override open var description: String {
        return String(format: "error %@[%d]: %@", domain, code, userInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }
}
