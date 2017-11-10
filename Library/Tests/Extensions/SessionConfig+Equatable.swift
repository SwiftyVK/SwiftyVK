@testable import SwiftyVK

extension SessionConfig: Equatable {
    
    public static func ==(lhs: SessionConfig, rhs: SessionConfig) -> Bool {
        if lhs.apiVersion != rhs.apiVersion { return false }
        if lhs.language.rawValue != rhs.language.rawValue { return false }
        if lhs.attemptsMaxLimit.count != rhs.attemptsMaxLimit.count { return false }
        if lhs.attemptsPerSecLimit.count != rhs.attemptsPerSecLimit.count { return false }
        if lhs.attemptTimeout != rhs.attemptTimeout { return false }
        if lhs.handleErrors != rhs.handleErrors { return false }
        return true
    }
}
