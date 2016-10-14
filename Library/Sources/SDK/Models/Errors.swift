import Foundation



public enum ErrorAuth: Int, CustomNSError, CustomStringConvertible {
    case presentingControllerIsNil  = 1
    case deniedFromUser             = 2
    case failingValidation          = 3
    case failingAuthorization       = 4
    
    public static let errorDomain = "SwiftyErrorAuth"
    public var errorCode: Int {return rawValue}
    public var errorUserInfo: [String : Any] {return [:]}
    
    public var description: String {
        return String(format: "error %@[%d]: %@", ErrorAuth.errorDomain, errorCode, errorUserInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }
}



public enum ErrorRequest: Int, CustomNSError, CustomStringConvertible {
    case unexpectedResponse         = 1
    case timeoutExpired             = 2
    case maximumAttemptsExceeded    = 3
    case responseParsingFailed      = 4
    case captchaFailed              = 5
    
    public static let errorDomain = "SwiftyErrorRequest"
    public var errorCode: Int {return rawValue}
    public var errorUserInfo: [String : Any] {return [:]}
    
    public var description: String {
        return String(format: "error %@[%d]: %@", ErrorRequest.errorDomain, errorCode, errorUserInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }
}



public struct ErrorAPI: CustomNSError, CustomStringConvertible {
    public static let errorDomain = "SwiftyErrorAPI"
    public private(set) var errorCode: Int = 0
    public var errorUserInfo = [String : Any]()
    
    public var description: String {
        return String(format: "error %@[%d]: %@", ErrorAPI.errorDomain, errorCode, errorUserInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }
    
    
    
    init(json: JSON) {
        
        if let message = json["error_msg"].string {
            errorCode = json["error_code"].intValue
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
        
        for (key, value) in json.dictionaryValue {
            if key != "request_params" && key != "error_code" && key != "error_msg" {
                errorUserInfo[key] = value.stringValue
            }
        }
    }
}


extension NSError {
    override open var description: String {
        return String(format: "error %@[%d]: %@", domain, code, userInfo[NSLocalizedDescriptionKey] as? String ?? "nil")
    }
}
