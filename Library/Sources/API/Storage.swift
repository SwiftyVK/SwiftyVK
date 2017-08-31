public extension VKAPI {
    public enum Storage: APIMethod {
        case get(Parameters)
        case set(Parameters)
        case getKeys(Parameters)
    }
}
