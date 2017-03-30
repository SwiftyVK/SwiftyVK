public extension Api {
    public enum Docs: String, Method {
        case get = "docs.get"
        case getById = "docs.getById"
        case getUploadServer = "docs.getUploadServer"
        case getWallUploadServer = "docs.getWallUploadServer"
        case save = "docs.save"
        case delete = "docs.delete"
        case add = "docs.add"
    }
}
