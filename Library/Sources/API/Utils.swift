extension PrivateVKAPI {
    public enum Utils: APIMethod {
        case checkLink(Parameters)
        case deleteFromLastShortened(Parameters)
        case getLastShortenedLinks(Parameters)
        case getLinkStats(Parameters)
        case getServerTime(Parameters)
        case getShortLink(Parameters)
        case resolveScreenName(Parameters)
    }
}
