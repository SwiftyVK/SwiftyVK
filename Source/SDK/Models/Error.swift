import Foundation



public class _VKError : Error, CustomStringConvertible {
  public var domain : String
  public var code: Int
  public var desc : String
  public var userInfo : [NSObject: AnyObject]?
  ///The reference to a request to the API, in which the error occurred
  public var request : Request?
  public var description : String {
    return "VK.Error \(domain)_(\(code)): \(desc)"
  }
  
  
  
  public init(err: NSError, req: Request?) {
    self.domain = err.domain
    self.code = err.code
    self.desc = err.localizedDescription
    self.userInfo = err.userInfo
    self.request = req
    
    if let request = request {
      VK.Log.put(request, "Init error of error and request \(self)")
    }
  }
  
  
  
  public init(domain: String, code: Int, desc: String, userInfo: [NSObject: AnyObject]?, req: Request?) {
    self.domain = domain
    self.code = code
    self.desc = desc
    self.userInfo = userInfo
    self.request = req
    
    if let request = request {
      VK.Log.put(request, "Init custom error \(self)")
    }
  }
  
  
  
  public init(json : JSON, request : Request) {
    self.request = request
    domain = "APIError"
    code = json["error_code"].intValue
    desc = json["error_msg"].stringValue
    var info = [NSObject : AnyObject]()
    
    for param in json["request_params"].arrayValue {
      info[param["key"].stringValue] = param["value"].stringValue
    }
    
    for (key, value) in json.dictionaryValue {
      if key != "request_params" && key != "error_code" {
        info[key] = value.stringValue
      }
    }
    
    userInfo = info
    
    VK.Log.put(request, "Init error of JSON \(self)")
  }
  
  
  
  public func `catch`() {
    if let request = request {
      VK.Log.put(request, "Catch error \(self)")
    }
    
    switch self.domain {
    case "APIError":
      catchAPIDomain()
    default:
      finaly()
    }
  }
  
  
  
  private func catchAPIDomain() {
    switch code {
    case 5:
      request?.authFails += 1
      request?.attempts -= 1
      Authorizator.authorize(request)
    case 6, 9, 10:
      Connection.needLimit = true
      finaly()
    case 14:
      if !sharedCaptchaIsRun {
        request?.attempts -= 1
        СaptchaController.start(
          sid: userInfo!["captcha_sid"] as! String,
          imageUrl: userInfo!["captcha_img"] as! String,
          request: request!)
      }
    case 17:
      request?.attempts -= 1
      WebController.validate(request!, validationUrl: userInfo!["redirect_uri"] as! String)
    default:
      finaly()
    }
  }
  
  
  
  public func finaly() {
    if let request = request {
      request.trySend()
    }
  }
  
  
  deinit {
    if let request = request {
      request.isAPI ? VK.Log.put(request, "DEINIT \(self)") : ()
    }
  }
}

