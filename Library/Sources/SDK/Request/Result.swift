import Foundation

enum Result: CustomStringConvertible {

    case data(JSON)
    case error(Error)
    
    init(from data: Data) {
        let parsingError: NSErrorPointer = nil
        var json = JSON(data: data, error: parsingError)
        
        if let parsingError = parsingError?.pointee {
//            VK.Log.put(request, "json not parsed")
            self = .error(parsingError)
        }
        else if json["error"].exists() {
            self = .error(ApiError(json: json["error"]))
        }
        else if json["response"].exists() {
//            VK.Log.put(request, "result contained response")
            self = .data(json["response"])
        }
        else if !json.isEmpty {
//            VK.Log.put(request, "result contained response")
            self = .data(json)
        }
        else {
//            VK.Log.put(request, "json not contain response or error")
            self = .error(RequestError.responseParsingFailed)
        }
    }

    @discardableResult
    internal mutating func setError(error: Error) -> Error {
        self = .error(error)
        return error
    }

    var description: String {
        switch self {
        case .data:
            return "result with response"
        case .error(let error):
            return "result with: \(error)"
        }
    }
}
