import Foundation



public enum VKAuthError: Int, Error, CustomStringConvertible {
    case presentingControllerIsNil  = 1
    case deniedFromUser             = 2
    case failingValidation          = 3
    
    public var description: String {
        return "RequestError \(rawValue)"
    }
}



public enum VKRequestError : Int, Error, CustomStringConvertible {
    case unexpectedResponse         = 1
    case timeoutExpired             = 2
    case maximumAttemptsExceeded    = 3
    case responseParsingFailed      = 4
    case captchaFailed              = 5

    public var description: String {
        return "AuthError \(rawValue)"
    }
}



public struct VKAPIError : Error, CustomStringConvertible, CustomNSError {
    public let code: Int
    public let message: String
    public let info: [String: Any]
    
    
    init(json: JSON) {
        code = json["error_code"].intValue
        message = json["error_msg"].stringValue
        var info = [String : Any]()
        
        for param in json["request_params"].arrayValue {
            info[param["key"].stringValue] = param["value"].stringValue
        }
        
        for (key, value) in json.dictionaryValue {
            if key != "request_params" && key != "error_code" && key != "error_msg" {
                info[key] = value.stringValue
            }
        }
        
        info[NSLocalizedDescriptionKey] = message
        self.info = info

    }
    
    
    public static var errorDomain: String {return "VKAPIError"}
    public var errorCode: Int {return code}
    public var errorUserInfo: [String : Any] {return info}
    
    public var description: String {
        return "ApiError \(code): \(message)" +
        "   info: \(info)"
    }
}
