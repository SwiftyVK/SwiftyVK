import Foundation

public struct Config {
    
    static let `default` = Config()
    
    let httpMethod: HttpMethod
    var language: Language {
        return _language ?? sessionConfig?.language ?? .default
    }
    var maxAttemptsLimit: AttemptLimit {
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
    
    private var _language: Language?
    private var _attemptsMaxLimit: AttemptLimit?
    private var _attemptTimeout: TimeInterval?
    private var _handleErrors: Bool?
    private var _enableLogging: Bool?
    private var sessionConfig: SessionConfig?
    
    init(
        httpMethod: HttpMethod = .GET,
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
    
    func mutated(
        language: Language? = nil,
        attemptLimit: AttemptLimit? = nil,
        attemptTimeout: TimeInterval? = nil,
        handleErrors: Bool? = nil,
        enableLogging: Bool? = nil
        ) -> Config {
        var newConfig = Config(
            httpMethod: httpMethod,
            language: language ?? _language,
            attemptsMaxLimit: attemptLimit ?? _attemptsMaxLimit,
            attemptTimeout: attemptTimeout ?? _attemptTimeout,
            handleErrors: handleErrors ?? _handleErrors,
            enableLogging: enableLogging ?? _enableLogging
        )
        
        if let sessionConfig = sessionConfig {
            newConfig.inject(sessionConfig: sessionConfig)
        }
        
        return newConfig
    }
}
