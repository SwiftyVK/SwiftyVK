public extension VKAPI {
    public enum Places: Methods.API {
        case add(Parameters)
        case getById(Parameters)
        case search(Parameters)
        case checkin(Parameters)
        case getCheckins(Parameters)
        case getTypes(Parameters)
    }
}
