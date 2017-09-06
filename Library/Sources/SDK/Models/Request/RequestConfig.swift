public struct Config {
    
    public static let `default` = Config()
    
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
    var enableLogging: Bool {
        return _enableLogging ?? sessionConfig?.enableLogging ?? false
    }
    
    private var _apiVersion: String?
    private var _language: Language?
    private var _attemptsMaxLimit: AttemptLimit?
    private var _attemptTimeout: TimeInterval?
    private var _handleErrors: Bool?
    private var _enableLogging: Bool?
    private var sessionConfig: SessionConfig?
    
    init(
        httpMethod: HttpMethod = .GET,
        apiVersion: String? = nil,
        language: Language? = nil,
        attemptsMaxLimit: AttemptLimit? = nil,
        attemptTimeout: TimeInterval? = nil,
        handleErrors: Bool? = nil,
        enableLogging: Bool? = nil
        ) {
        self.httpMethod = httpMethod
        _language = language
        _attemptsMaxLimit = attemptsMaxLimit
        _attemptTimeout = attemptTimeout
        _handleErrors = handleErrors
        _enableLogging = enableLogging
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
            handleErrors: other._handleErrors ?? _handleErrors,
            enableLogging: other._enableLogging ?? _enableLogging
        )
        
        sessionConfig.flatMap { newConfig.inject(sessionConfig: $0) }

        return newConfig
    }
}
