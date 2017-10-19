extension APIScope {
    /// https://vk.com/dev/status
    public enum Status: APIMethod {
        case get(Parameters)
        case set(Parameters)
    }
}
