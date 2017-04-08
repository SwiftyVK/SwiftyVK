public extension VK.Api {
    public enum Docs: Method {
        public var _group: String { return "docs" }
        
        case get(Parameters)
        case getById(Parameters)
        case getUploadServer(Parameters)
        case getWallUploadServer(Parameters)
        case save(Parameters)
        case delete(Parameters)
        case add(Parameters)
    }
}
