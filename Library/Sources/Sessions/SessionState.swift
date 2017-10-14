public enum SessionState: Int, Comparable, Codable {
    case destroyed = -1
    case initiated = 0
    case authorized = 1
    
    public static func == (lhs: SessionState, rhs: SessionState) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public static func < (lhs: SessionState, rhs: SessionState) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
