import Foundation

enum LegacyResult: CustomStringConvertible {

    case data(JSON)
    case error(Error)
    
    init(from data: Data) {
        let parsingError: NSErrorPointer = nil
        var json = JSON(data: data, error: parsingError)
        
        if let parsingError = parsingError?.pointee {
            self = .error(parsingError)
        }
        else if json["error"].exists() {
            self = .error(LegacyApiError(json: json["error"]))
        }
        else if json["response"].exists() {
            self = .data(json["response"])
        }
        else if !json.isEmpty {
            self = .data(json)
        }
        else {
            self = .error(RequestError.responseParsingFailed)
        }
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
