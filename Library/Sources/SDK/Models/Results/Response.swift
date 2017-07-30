import Foundation

public enum Response {
    case success(Data)
    case error(VkError)
    
    init(_ data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            if let apiError = ApiError(json) {
                self = .error(.api(apiError))
                return
            }
            
            if let root = json as? [String: Any], let success = root["success"] {
                let successData = try JSONSerialization.data(withJSONObject: success, options: [])
                self = .success(successData)
                return
            }
            
            self = .success(data)
        } catch let error {
            self = .error(.request(.jsonNotParsed(error)))
            return
        }
    }
}
