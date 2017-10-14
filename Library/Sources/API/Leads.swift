extension APIScope {
    public enum Leads: APIMethod {
        case checkUser(Parameters)
        case complete(Parameters)
        case getStats(Parameters)
        case getUsers(Parameters)
        case metricHit(Parameters)
        case start(Parameters)
    }
}
