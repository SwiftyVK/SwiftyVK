import Foundation

public enum Response {
    case success(Data)
    case error(VkError)
    
    init(_ data: Data) {
        do {
            let json = try JSON(data: data)
            
            if let apiError = ApiError(json) {
                self = .error(.api(apiError))
                return
            }
            
            let successData = json.forcedData("success")
            
            if successData.isEmpty {
                self = .success(data)
            } else {
                self = .success(successData)
            }
        } catch let error {
            self = .error(.request(.jsonNotParsed(error)))
            return
        }
    }
}
