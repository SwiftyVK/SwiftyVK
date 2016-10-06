import Foundation



internal struct Result: CustomStringConvertible {
    internal private(set) var error : Error? {
        didSet {response != nil ? response = nil : ()}
    }
    internal private(set) var response : JSON? {
        didSet {error != nil ? error = nil : ()}
    }
    
    
    internal mutating func parseResponseFrom(data: Data) {
            let parsingError: NSErrorPointer = nil
            var json = JSON(data: data, error: parsingError)
        
            if let parsingError = parsingError?.pointee {
                error = parsingError
            }
                
            else if json["response"].exists() {
                response = json["response"]
            }
                
            else if json["error"].exists() {
                error = VKAPIError(json: json["error"])
            }
                
            else {
                error = VKRequestError.responseParsingFailed
            }
    }
    
    
    
    internal mutating func setError(error: Error) {
        self.error = error
    }
    
    
    var description: String {
        if response != nil {
            return "Result with response"
        }
        else if let error = error as? NSError {
            return "Result with: NSError \(error.code) \(error.localizedDescription)"
        }
        else if let error = error {
            return "Result with: \(error)"
        }
        
        return "Empty result"
    }
}
