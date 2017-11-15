import Foundation

enum Response {
    case success(Data)
    case error(VKError)
    
    init(_ data: Data) {
        do {
            let json = try JSON(data: data)
            
            if let apiError = ApiError(json) {
                self = .error(.api(apiError))
                return
            }
            
            let successData = json.forcedData("response")
            
            if successData.isEmpty {
                self = .success(data)
            }
            else {
                self = .success(successData)
            }
        }
        catch let error {
            self = .error(.jsonNotParsed(error))
            return
        }
    }
}
