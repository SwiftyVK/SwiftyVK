public final class SessionConfig {
    
    public static var apiVersion = "5.62"
    public static let sdkVersion = "1.3.17"
    public var language: Language
    public var attemptLimit: AttemptLimit
    public var attemptTimeout: TimeInterval
    public var handleErrors: Bool
    public var enableLogging: Bool
    
    init(
        language: Language = .default,
        attemptLimit: AttemptLimit = .default,
        attemptTimeout: TimeInterval = 10,
        handleErrors: Bool = true,
        enableLogging: Bool = false
        ) {
        self.language = language
        self.attemptLimit = attemptLimit
        self.attemptTimeout = attemptTimeout
        self.handleErrors = handleErrors
        self.enableLogging = enableLogging
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
    
    static var `default`: Language {
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
