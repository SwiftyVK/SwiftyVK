import Foundation



private let responseQueue = DispatchQueue(label: "com.VK.responseQueue", attributes: .concurrent)



internal final class Response {
  internal weak var request : Request?
  internal private(set) var error : VK.Error? {
    didSet {success != nil ? success = nil : ()}
  }
  internal private(set) var success : JSON? {
    didSet {error != nil ? error = nil : ()}
  }
  
  
  internal func setError(_ newError: VK.Error) {
    error = newError
  }
  
  
  
  internal func create(_ data: Data?) {
    if data != nil {
      var err : NSErrorPointer
      err = nil
      var json = JSON(data: data!, error: err)
      
      if let err = err?.pointee {
        error = VK.Error(err: err, req: request!)
      }
        
      else if json["response"].exists() {
        VK.Log.put(request!, "Parse response data to success")
        success = json["response"]
      }
        
      else if json["error"].exists() {
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
  
  
  
  internal func execute() {
    guard let request = request, request.cancelled == false else {return}
    
    if let error = error {
      if request.catchErrors {
        error.`catch`()
      }
      else if request.canSend == true {
        request.trySend()
      }
      else {
        request.isAPI == true && request.asynchronous == false
          ? executeError()
          : responseQueue.async {self.executeError()}
      }
    }
    else if let _ = success {
      request.isAPI == true && request.asynchronous == false
        ? executeSuccess()
        : responseQueue.async {self.executeSuccess()}
    }
    else {
      VK.Log.put(request, "Response data is not set")
    }
  }
  
  
  
  internal func executeError() {
    guard let request = request, request.cancelled == false else {return}
    
    guard request.errorBlockIsSet else {
      VK.Log.put(request, "Error block is not set")
      return
    }
    guard let error = error else {
      VK.Log.put(request, "Error is not set")
      return
    }
    
    VK.Log.put(request, "Executing error block")
    request.errorBlock(error)
    clean()
    VK.Log.put(request, "Error block is executed")
  }
  
  
  
  internal func executeSuccess() {
    guard let request = request, request.cancelled == false else {return}
    
    guard request.successBlockIsSet else {
      VK.Log.put(request, "Success block is not set")
      return
    }
    guard let success = success else {
      VK.Log.put(request, "Success is not set")
      return
    }
    
    VK.Log.put(request, "Executing success block")
    request.successBlock(success)
    clean()
    VK.Log.put(request, "Success block is executed")
  }
  
  
  internal func clean() {
    self.success = nil
    self.error = nil
  }
}
