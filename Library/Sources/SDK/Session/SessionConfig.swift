public final class SessionConfig {
    
    public static let `default` = SessionConfig()
    
    public static var apiVersion = "5.62"
    public static let sdkVersion = "1.3.17"
    public var language: Language
    public var attemptLimit: AttemptLimit
    public var attemptTimeout: TimeInterval
    public var handleErrors: Bool
    public var enableLogging: Bool
    
    public var limitPerSec: AttemptLimit {
        didSet {
            onLimitPerSecChange?(limitPerSec)
        }
    }
    
    var onLimitPerSecChange: ((AttemptLimit) -> ())?
    
    public init(
        language: Language = .default,
        attemptLimit: AttemptLimit = .default,
        attemptTimeout: TimeInterval = 10,
        handleErrors: Bool = true,
        enableLogging: Bool = false,
        limitPerSec: AttemptLimit = .default
        ) {
        self.language = language
        self.attemptLimit = attemptLimit
        self.attemptTimeout = attemptTimeout
        self.handleErrors = handleErrors
        self.enableLogging = enableLogging
        self.limitPerSec = limitPerSec
    }
}

public enum Language: String {
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

public enum AttemptLimit {
    static let `default` = AttemptLimit.limited(3)
    
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
}
