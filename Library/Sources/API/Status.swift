extension APIScope {
    /// https://vk.ru/dev/status
    public enum Status: APIMethod {
        case get(Parameters)
        case set(Parameters)
    }
}
