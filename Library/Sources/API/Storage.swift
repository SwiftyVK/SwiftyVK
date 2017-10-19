extension APIScope {
    /// https://vk.com/dev/storage
    public enum Storage: APIMethod {
        case get(Parameters)
        case getKeys(Parameters)
        case set(Parameters)
    }
}
