public extension VK.Api {
    public enum Places: APIMethod {
        case add(Parameters)
        case getById(Parameters)
        case search(Parameters)
        case checkin(Parameters)
        case getCheckins(Parameters)
        case getTypes(Parameters)
    }
}
