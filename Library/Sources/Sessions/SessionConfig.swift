import Foundation

/// Respesent config of VK user session
public struct SessionConfig: Codable {
    /// Current default supported apiVersion
    public static let currentApiVersion = "5.69"
    
    /// Config with default values
    public static let `default` = SessionConfig()
    
    /// VK API version. By default uses latest version.
    public var apiVersion = SessionConfig.currentApiVersion
    /// Response language.
    public var language: Language
    public var attemptsMaxLimit: AttemptLimit
    /// Maximum number of attempts to send request before returning an error.
    public var attemptsPerSecLimit: AttemptLimit
    /// Timeout in seconds of waiting request before returning an error.
    public var attemptTimeout: TimeInterval
    /// Allows automatically handle specific VK errors
    /// like authorization, captcha, validation nedеed and present dialog to user for resolve this situation.
    public var handleErrors: Bool
    
    let sdkVersion = "1.3.17"
    
    /// Init new sconfig
    /// - parameter apiVersion: VK API version. By default uses latest version.
    /// If you need different version - change this value.
    ///
    /// - parameter language: Language of response. For EN Pavel Durov, for RU Павел Дуров.
    ///
    /// - parameter attemptsMaxLimit: Maximum number of attempts to send request before returning an error.
    ///
    /// - parameter attemptTimeout: Timeout in seconds of waiting request before returning an error.
    ///
    /// - parameter handleErrors: Allows automatically handle specific VK errors
    /// like authorization, captcha, validation nedеed and present dialog to user for resolve this situation.
    public init(
        apiVersion: String? = SessionConfig.currentApiVersion,
        language: Language? = .default,
        attemptsMaxLimit: AttemptLimit? = .default,
        attemptsPerSecLimit: AttemptLimit? = .default,
        attemptTimeout: TimeInterval? = 10,
        handleErrors: Bool? = true
        ) {
        self.apiVersion = apiVersion ?? SessionConfig.currentApiVersion
        self.language = language ?? .default
        self.attemptsMaxLimit = attemptsMaxLimit ?? .default
        self.attemptsPerSecLimit = attemptsPerSecLimit ?? .default
        self.attemptTimeout = attemptTimeout ?? 10
        self.handleErrors = handleErrors ?? true
    }
}

/// Language of request responses
public enum Language: String, Codable {
    case ru
    case ua
    case be
    case en
    case es
    case fi
    case de
    case it
    
    /// Returns system language or .en
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

/// Represents limit attempts of sending request.
/// - unlimited: = zero = infinity attemps
/// - limited: Count of attempts
/// Can init with integer literal.
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
