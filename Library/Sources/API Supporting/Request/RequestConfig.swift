import Foundation

/// Represents request config
public struct Config {
    
    /// Config vith default values
    public static let `default` = Config()
    
    static let upload: Config = {
        var config = Config(httpMethod: .POST)
        config.handleProgress = true
        return config
    }()
    
    let httpMethod: HttpMethod
    
    var apiVersion: String? {
        return _apiVersion ?? sessionConfig?.apiVersion
    }
    var language: Language {
        return _language ?? sessionConfig?.language ?? .default
    }
    var attemptsMaxLimit: AttemptLimit {
        return _attemptsMaxLimit ?? sessionConfig?.attemptsMaxLimit ?? .default
    }
    var attemptTimeout: TimeInterval {
        return _attemptTimeout ?? sessionConfig?.attemptTimeout ?? 10
    }
    var handleErrors: Bool {
        return _handleErrors ?? sessionConfig?.handleErrors ?? true
    }
    
    private(set) var handleProgress: Bool = false
    
    private var _apiVersion: String?
    private var _language: Language?
    private var _attemptsMaxLimit: AttemptLimit?
    private var _attemptTimeout: TimeInterval?
    private var _handleErrors: Bool?
    private var sessionConfig: SessionConfig?
    
    /// Init new sconfig
    /// - parameter httpMethod: HTTP method. You can use GET or POST.
    /// For big body (e.g. long message text in message.send method) use POST method.
    ///
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
        httpMethod: HttpMethod = .GET,
        apiVersion: String? = nil,
        language: Language? = nil,
        attemptsMaxLimit: AttemptLimit? = nil,
        attemptTimeout: TimeInterval? = nil,
        handleErrors: Bool? = nil
        ) {
        self.httpMethod = httpMethod
        _language = language
        _attemptsMaxLimit = attemptsMaxLimit
        _attemptTimeout = attemptTimeout
        _handleErrors = handleErrors
    }
    
    mutating func inject(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
    }
    
    func overriden(with other: Config) -> Config {
        var newConfig = Config(
            httpMethod: httpMethod,
            apiVersion: other._apiVersion ?? _apiVersion,
            language: other._language ?? _language,
            attemptsMaxLimit: other._attemptsMaxLimit ?? _attemptsMaxLimit,
            attemptTimeout: other._attemptTimeout ?? _attemptTimeout,
            handleErrors: other._handleErrors ?? _handleErrors
        )
        
        newConfig.handleProgress = other.handleProgress
        
        sessionConfig.flatMap { newConfig.inject(sessionConfig: $0) }

        return newConfig
    }
}
