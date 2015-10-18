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
        success = json["response"]
        Log([LogOption.response], "Parse data to success: \(success)")
      }
        
      else if json["error"].count > 0 {
        error = VK.Error(json: json["error"], request: request!)
        Log([LogOption.error], "Parse data to error: \(error)")
      }
        
      else {
        success = json
        Log([LogOption.error], "Parse root data to success: \(success)")
      }
    }
    else {
      Log([LogOption.response, LogOption.error], "Parse data failed.")
    }
  }
  
  
  
  init() {
    Log([LogOption.life], "\(self) INIT")
  }
  
  
  
  deinit {
    Log([LogOption.life], "\(self) DEINIT")
  }
}