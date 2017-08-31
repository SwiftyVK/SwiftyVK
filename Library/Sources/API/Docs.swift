public extension VK.Api {
    public enum Docs: APIMethod {
        case get(Parameters)
        case getById(Parameters)
        case getUploadServer(Parameters)
        case getWallUploadServer(Parameters)
        case save(Parameters)
        case delete(Parameters)
        case add(Parameters)
    }
}
