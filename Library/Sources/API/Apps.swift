extension APIScope {
    /// https://vk.ru/dev/apps
    public enum Apps: APIMethod {
        case deleteAppRequests(Parameters)
        case get(Parameters)
        case getCatalog(Parameters)
        case getFriendsList(Parameters)
        case getLeaderboard(Parameters)
        case getScore(Parameters)
        case sendRequest(Parameters)
    }
}
