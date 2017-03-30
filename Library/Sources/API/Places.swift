public extension Api {
    public enum Places: String, Method {
        case add = "places.add"
        case getById = "places.getById"
        case search = "places.search"
        case checkin = "places.checkin"
        case getCheckins = "places.getCheckins"
        case getTypes = "places.getTypes"
    }
}
