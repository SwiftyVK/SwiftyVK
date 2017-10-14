extension APIScope {
    public enum Storage: APIMethod {
        case get(Parameters)
        case getKeys(Parameters)
        case set(Parameters)
    }
}
