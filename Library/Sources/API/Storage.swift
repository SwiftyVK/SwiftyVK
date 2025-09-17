extension APIScope {
    /// https://vk.ru/dev/storage
    public enum Storage: APIMethod {
        case get(Parameters)
        case getKeys(Parameters)
        case set(Parameters)
    }
}
