import Foundation

public struct ApiError {
    public let code: Int
    public let message: String
    public private(set) var requestParams = [String : String]()
    public private(set) var otherInfo = [String : String]()
    
    init?(_ json: Any) {
        guard let rootDict = json as? [String: Any] else {
            return nil
        }
        
        guard let errorDict = rootDict["error"] as? [String: Any] else {
            return nil
        }
        
        guard let errorCode = errorDict["error_code"] as? Int else {
            return nil
        }
        
        guard let errorMessage = errorDict["error_msg"] as? String else {
            return nil
        }
        
        code = errorCode
        message = errorMessage
        requestParams = makeRequestParams(from: errorDict)
        otherInfo = makeOtherInfo(from: errorDict)
    }
    
    private func makeRequestParams(from errorDict: [String: Any]) -> [String : String] {
        var paramsDict = [String : String]()
        
        if let paramsArray = errorDict["request_params"] as? [[String: String]] {
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
}
