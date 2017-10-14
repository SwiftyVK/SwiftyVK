extension APIScope {
    public enum Status: APIMethod {
        case get(Parameters)
        case set(Parameters)
    }
}
