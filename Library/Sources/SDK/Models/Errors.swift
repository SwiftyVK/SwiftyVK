import Foundation

public enum SessionError: Int, CustomNSError, CustomStringConvertible {
    case nilParentView              = 1
    case deniedFromUser             = 2
    case failedValidation           = 3
    case failedAuthorization        = 4
    case notConfigured              = 5
    case delegateNotFound           = 6
    case cantDestroyDefaultSession  = 7
    case sessionDestroyed           = 8
    case tokenNotSavedInStorage     = 9
    case cantBuildUrlForVkApp       = 10
    case authCalledFromMainThread   = 11

    public static let errorDomain = "SwiftyVKSessionError"
    public var errorCode: Int {return rawValue}
    public var errorUserInfo: [String : Any] {return [:]}

    public var description: String {
        return String(format: "error %@[%d]: %@", SessionError.errorDomain, errorCode, errorUserInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }
}

public enum RequestError: Int, CustomNSError, CustomStringConvertible {
    case unexpectedResponse         = 1
    case timeoutExpired             = 2
    case maximumAttemptsExceeded    = 3
    case responseParsingFailed      = 4
    case captchaFailed              = 5
    case notConfigured              = 6
    case wrongTaskType              = 7
    case wrongAttemptType           = 8
    case wrongUrl                   = 9

    public static let errorDomain = "SwiftyVKRequestError"
    public var errorCode: Int {return rawValue}
    public var errorUserInfo: [String : Any] {return [:]}

    public var description: String {
        return String(format: "error %@[%d]: %@", RequestError.errorDomain, errorCode, errorUserInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }
}

public struct ApiError: CustomNSError, CustomStringConvertible {
    public static let errorDomain = "SwiftyVKApiError"
    public private(set) var errorCode: Int = 0
    public var errorUserInfo = [String: Any]()

    public var description: String {
        return String(format: "error %@[%d]: %@", ApiError.errorDomain, errorCode, errorUserInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }

    init(json: JSON) {
        
        if let message = json["error_msg"].string {
            errorCode  = json["error_code"].intValue
            errorUserInfo[NSLocalizedDescriptionKey] = message
        }
        else if let message = json.string {
            errorUserInfo[NSLocalizedDescriptionKey] = message
        }
        else {
            errorUserInfo[NSLocalizedDescriptionKey] = "unknown error"
        }
        
        for param in json["request_params"].arrayValue {
            errorUserInfo[param["key"].stringValue] = param["value"].stringValue
        }
        
        for (key, value) in json.dictionaryValue where key != "request_params" && key != "error_code" && key != "error_msg" {
            errorUserInfo[key] = value.stringValue
        }
    }
}

extension NSError {
    override open var description: String {
        return String(format: "error %@[%d]: %@", domain, code, userInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }
}
