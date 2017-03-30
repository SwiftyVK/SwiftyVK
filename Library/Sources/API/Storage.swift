public extension Api {
    public enum Storage: String, Method {
        case get = "storage.get"
        case set = "storage.set"
        case getKeys = "storage.getKeys"
    }
}
