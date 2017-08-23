public struct Scopes: OptionSet {
    public let rawValue: Int
    
    static let notify = Scopes(rawValue: 1)
    static let friends = Scopes(rawValue: 2)
    static let photos = Scopes(rawValue: 4)
    static let audio = Scopes(rawValue: 8)
    static let video = Scopes(rawValue: 16)
    static let docs = Scopes(rawValue: 131072)
    static let notes = Scopes(rawValue: 2048)
    static let pages = Scopes(rawValue: 128)
    static let status = Scopes(rawValue: 1024)
    static let offers = Scopes(rawValue: 32)
    static let questions = Scopes(rawValue: 64)
    static let wall = Scopes(rawValue: 8192)
    static let groups = Scopes(rawValue: 262144)
    static let messages = Scopes(rawValue: 4096)
    static let email = Scopes(rawValue: 4194304)
    static let notifications = Scopes(rawValue: 524288)
    static let stats = Scopes(rawValue: 1048576)
    static let ads = Scopes(rawValue: 32768)
    static let offline = Scopes(rawValue: 65536)
    static let market = Scopes(rawValue: 134217728)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
