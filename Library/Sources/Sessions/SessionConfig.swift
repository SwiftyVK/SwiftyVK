public struct SessionConfig: Codable {
    
    public static let `default` = SessionConfig()
    
    public var apiVersion = "5.68"
    public let sdkVersion = "1.3.17"
    public var language: Language
    public var attemptsMaxLimit: AttemptLimit
    public var attemptsPerSecLimit: AttemptLimit
    public var attemptTimeout: TimeInterval
    public var handleErrors: Bool
    public var enableLogging: Bool
    
    public init(
        language: Language = .default,
        attemptsMaxLimit: AttemptLimit = .default,
        attemptsPerSecLimit: AttemptLimit = .default,
        attemptTimeout: TimeInterval = 10,
        handleErrors: Bool = true,
        enableLogging: Bool = false
        ) {
        self.language = language
        self.attemptsMaxLimit = attemptsMaxLimit
        self.attemptsPerSecLimit = attemptsPerSecLimit
        self.attemptTimeout = attemptTimeout
        self.handleErrors = handleErrors
        self.enableLogging = enableLogging
    }
}

public enum Language: String, Codable {
    case ru
    case ua
    case be
    case en
    case es
    case fi
    case de
    case it
    
    public static var `default`: Language {
        return system ?? .en
    }
    
    static var system: Language? {
        let languages: [Language] = [.ru, .ua, .be, .en, .es, .fi, .de, .it]
        let rawLanguages = languages.map { $0.rawValue }
        guard let systemLanguage = Bundle.preferredLocalizations(from: rawLanguages).first else {
            return nil
        }
        
        return Language(rawValue: systemLanguage)
    }
}

public enum AttemptLimit: Codable, ExpressibleByIntegerLiteral {
    
    public static let `default` = AttemptLimit.limited(3)
    
    case unlimited
    case limited(Int)
    
    var count: Int {
        switch self {
        case .unlimited:
            return 0
        case .limited(let limit):
            return limit
        }
    }
    
    public init(integerLiteral value: Int) {
        if value <= 0 {
            self = .unlimited
        }
        else {
            self = .limited(value)
        }
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let value = try container.decodeIfPresent(Int.self)
        
        if let value = value {
            self = .limited(value)
        }
        else {
            self = .unlimited
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        var value: Int?
        
        switch self {
        case .limited(let limit):
            value = limit
        case .unlimited:
            break
        }
        
        try container.encode(value)
    }
}
