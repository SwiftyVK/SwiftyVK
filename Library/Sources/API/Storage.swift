public extension VK.Api {
    public enum Storage: Method {        
        case get(Parameters)
        case set(Parameters)
        case getKeys(Parameters)
    }
}
