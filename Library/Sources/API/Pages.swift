public extension Api {
    public enum Pages: String, Method {
        case get = "pages.get"
        case save = "pages.save"
        case saveAccess = "pages.saveAccess"
        case getHistory = "pages.getHistory"
        case getTitles = "pages.getTitles"
        case getVersion = "pages.getVersion"
        case parseWiki = "pages.parseWiki"
        case clearCache = "pages.clearCache"
    }
}
