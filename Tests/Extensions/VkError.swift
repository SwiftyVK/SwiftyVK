@testable import SwiftyVK

extension VkError: Equatable {
    public static func ==(lhs: VkError, rhs: VkError) -> Bool {
        switch (lhs, rhs) {
        case let (api(first), api(second)):
            return first == second
        case let (request(first), request(second)):
            return first == second
        case let (session(first), session(second)):
            return first == second
        case (_, _):
            return false
        }
    }
}
