public extension VK.Api {
    public enum Places: Method {
        case add(Parameters)
        case getById(Parameters)
        case search(Parameters)
        case checkin(Parameters)
        case getCheckins(Parameters)
        case getTypes(Parameters)
    }
}
