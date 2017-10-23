extension APIScope {
    /// https://vk.com/dev/places
    public enum Places: APIMethod {
        case add(Parameters)
        case checkin(Parameters)
        case getById(Parameters)
        case getCheckins(Parameters)
        case getTypes(Parameters)
        case search(Parameters)
    }
}
