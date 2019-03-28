@testable import SwiftyVK

extension Media: Equatable {
    public static func ==(lhs: Media, rhs: Media) -> Bool {
        return lhs.data == rhs.data
    }
}


extension Request: Hashable {
    
    public static func ==(lhs: Request, rhs: Request) -> Bool {
        return lhs.type == rhs.type
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type.hashValue)
    }
}
