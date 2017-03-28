import Foundation



internal struct Result: CustomStringConvertible {
    private unowned let request: RequestInstance

    internal private(set) var error: Error? {
        didSet {
            error != nil && response != nil ? response = nil : ()
            guard let error = error else {return}
            VK.Log.put(request, "result contained \(error)")
        }
    }
    
    internal private(set) var response: JSON? {
        didSet {error != nil && response != nil ? error = nil : ()}
    }



    init(request: RequestInstance) {
        self.request = request
    }


    internal mutating func parseResponseFrom(data: Data) {
            let parsingError: NSErrorPointer = nil
            var json = JSON(data: data, error: parsingError)

            if let parsingError = parsingError?.pointee {
                VK.Log.put(request, "json not parsed")
                error = parsingError
            }
            else if json["response"].exists() {
                VK.Log.put(request, "result contained response")
                response = json["response"]
            }
            else if json["error"].exists() {
                error = ApiError(json: json["error"])
            }
            else if !json.isEmpty {
                VK.Log.put(request, "result contained response")
                response = json
            }
            else {
                VK.Log.put(request, "json not contain response or error")
                error = RequestError.responseParsingFailed
            }
    }



    @discardableResult
    internal mutating func setError(error: Error) -> Error {
        self.error = error
        return error
    }



    var description: String {
        if response != nil {
            return "result with response"
        }
        else if let error = error as NSError? {
            return "result with: \(error)"
        }
        else if let error = error {
            return "result with: \(error)"
        }

        return "result empty"
    }
}
