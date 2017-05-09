public enum SessionState: Int, Comparable {
    case initiated = 0
    case activated = 1
    case authorized = 2
    
    public static func == (lhs: SessionState, rhs: SessionState) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public static func < (lhs: SessionState, rhs: SessionState) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
