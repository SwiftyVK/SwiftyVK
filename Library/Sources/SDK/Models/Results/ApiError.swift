import Foundation

public struct ApiError: Equatable {
    public let code: Int
    public let message: String
    public private(set) var requestParams = [String : String]()
    public private(set) var otherInfo = [String : String]()
    
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
    
    var toVk: VkError {
        return .api(self)
    }
    
    private func makeRequestParams(from error: JSON) -> [String : String] {
        var paramsDict = [String : String]()
        
        if let paramsArray: [[String: String]] = error.array("error, request_params") {
            for param in paramsArray {
                if let key = param["key"], let value = param["value"] {
                    paramsDict.updateValue(value, forKey: key)
                }
            }
        }
        
        return paramsDict
    }
    
    private func makeOtherInfo(from errorDict: [String: Any]) -> [String : String] {
        var infoDict = [String : String]()
        let ignoredKeys = ["error_code", "error_msg", "request_params"]
        
        for (key, value) in errorDict {
            if !ignoredKeys.contains(key), let stringValue = value as? String {
                infoDict.updateValue(stringValue, forKey: key)
            }
        }
        
        return infoDict
    }
    
    public static func ==(lhs: ApiError, rhs: ApiError) -> Bool {
        return lhs.code == rhs.code
    }
}
