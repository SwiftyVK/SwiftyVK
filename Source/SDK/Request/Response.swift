import Foundation



internal class Response {
  weak var request : Request?
  var error : VK.Error? {
    didSet {success != nil ? success = nil : ()}
  }
  var success : JSON? {
    didSet {error != nil ? error = nil : ()}
  }
  
  
  
  func create(data: NSData?) {
    if data != nil {
      var err : NSError?
      var json = JSON(data: data!, error: &err)
            
      if err != nil {
        error = VK.Error(ns: err!, req: request!)
      }
        
      else if json["response"].count > 0 {
        VK.Log.put(request!, "Parse response data to success")
        success = json["response"]
      }
        
      else if json["error"].count > 0 {
        VK.Log.put(request!, "Parse response data to error:")
        error = VK.Error(json: json["error"], request: request!)
      }
        
      else {
        VK.Log.put(request!, "Parse response data to sucsess")
        success = json
      }
    }
    else {
      VK.Log.put(request!, "Fail parse response data")
      error = VK.Error(domain: "VKSDKDomain", code: 4, desc: "Fail parse response data", userInfo: nil, req: request)
    }
  }
}