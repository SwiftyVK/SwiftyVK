import Foundation



internal final class Result {
    internal private(set) var error : Error? {
        didSet {success != nil ? success = nil : ()}
    }
    internal private(set) var success : JSON? {
        didSet {error != nil ? error = nil : ()}
    }
    
    
//    internal func create(_ data: Data?) {
//        if data != nil {
//            var err : NSErrorPointer
//            err = nil
//            var json = JSON(data: data!, error: err)
//            
//            if let err = err?.pointee {
//                error = VKError(error: err, request: request!)
//            }
//                
//            else if json["response"].exists() {
//                VK.Log.put(request!, "Parse response data to success")
//                success = json["response"]
//            }
//                
//            else if json["error"].exists() {
//                VK.Log.put(request!, "Parse response data to error:")
//                error = VKError(json: json["error"], request: request!)
//            }
//                
//            else {
//                VK.Log.put(request!, "Parse response data to sucsess")
//                success = json
//            }
//        }
//        else {
//            VK.Log.put(request!, "Fail parse response data")
//            error = VKError(code: 4, desc: "Fail parse response data", request: request)
//        }
//    }
}
