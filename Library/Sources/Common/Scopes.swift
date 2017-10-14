public struct Scopes: OptionSet {
    public let rawValue: Int
    
    public static let notify = Scopes(rawValue: 1)
    public static let friends = Scopes(rawValue: 2)
    public static let photos = Scopes(rawValue: 4)
    public static let audio = Scopes(rawValue: 8)
    public static let video = Scopes(rawValue: 16)
    public static let docs = Scopes(rawValue: 131_072)
    public static let notes = Scopes(rawValue: 2_048)
    public static let pages = Scopes(rawValue: 128)
    public static let status = Scopes(rawValue: 1_024)
    public static let offers = Scopes(rawValue: 32)
    public static let questions = Scopes(rawValue: 64)
    public static let wall = Scopes(rawValue: 8_192)
    public static let groups = Scopes(rawValue: 262_144)
    public static let messages = Scopes(rawValue: 4_096)
    public static let email = Scopes(rawValue: 4_194_304)
    public static let notifications = Scopes(rawValue: 524_288)
    public static let stats = Scopes(rawValue: 1_048_576)
    public static let ads = Scopes(rawValue: 32_768)
    public static let offline = Scopes(rawValue: 65_536)
    public static let market = Scopes(rawValue: 134_217_728)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
