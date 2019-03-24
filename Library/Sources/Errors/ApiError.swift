import Foundation

/// Represents Error recieved from VK API. More info - https://vk.com/dev/errors
public struct ApiError: Equatable {
    /// Error code
    public let code: Int
    /// Error message
    public let message: String
    /// Parameters of sended request
    public internal(set) var requestParams = [String: String]()
    /// Other info about error
    public internal(set) var otherInfo = [String: String]()
    
    init?(_ json: JSON) {
        
        guard let errorCode = json.int("error, error_code") else {
            return nil
        }
        
        guard let errorMessage = json.string("error, error_msg") else {
            return nil
        }
        
        code = errorCode
        message = errorMessage
        requestParams = makeRequestParams(from: json)
        otherInfo = makeOtherInfo(from: json.forcedDictionary("error"))
    }
    
    // Only for unit tests
    init(code: Int, otherInfo: [String: String] = [:]) {
        self.code = code
        self.message = ""
        self.requestParams = [:]
        self.otherInfo = otherInfo
    }
    
    var toVK: VKError {
        return .api(self)
    }
    
    private func makeRequestParams(from error: JSON) -> [String: String] {
        var paramsDict = [String: String]()
        
        if let paramsArray: [[String: String]] = error.array("error, request_params") {
            for param in paramsArray {
                if let key = param["key"], let value = param["value"] {
                    paramsDict.updateValue(value, forKey: key)
                }
            }
        }
        
        return paramsDict
    }
    
    private func makeOtherInfo(from errorDict: [String: Any]) -> [String: String] {
        var infoDict = [String: String]()
        let ignoredKeys = ["error_code", "error_msg", "request_params"]
        
        for (key, value) in errorDict {
            if !ignoredKeys.contains(key), let stringValue = value as? String {
                infoDict.updateValue(stringValue, forKey: key)
            }
        }
        
        return infoDict
    }
    
    public static func == (lhs: ApiError, rhs: ApiError) -> Bool {
        return lhs.code == rhs.code
    }
}
