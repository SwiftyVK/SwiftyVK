import Foundation



public class _VKError : ErrorType, CustomStringConvertible {
  public var domain : String
  public var code: Int
  public var desc : String
  public var userInfo : [NSObject: AnyObject]?
  ///The reference to a request to the API, in which the error occurred
  public var request : Request?
  public var description : String {
    var result = "VK Error\r"
    result += "request: \(request != nil ? request : nil)\r"
    result += "code: \(code)\r"
    result += "description: \(desc)\r"
    userInfo != nil ? result += "userInfo: \(NSDictionary(dictionary: userInfo!))" : ()
    return result
  }
  
  
  
  public init(ns: NSError, req: Request?) {
    self.domain = ns.domain
    self.code = ns.code
    self.desc = ns.localizedDescription
    self.userInfo = ns.userInfo
    self.request = req
  }
  
  
  
  public init(domain: String, code: Int, desc: String, userInfo: [NSObject: AnyObject]?, req: Request?) {
    self.domain = domain
    self.code = code
    self.desc = desc
    self.userInfo = userInfo
    self.request = req
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
  }
  
  
  
  public func `catch`() {
    Log([.error], "Catch: \(self)")
    
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
      request?.attempts--
      VK.autorize(request)
    case 6, 9, 10:
      usleep(500000)
      request?.reSend()
    case 14:
      if !sharedCaptchaIsRun {
        request?.attempts--
        СaptchaController.start(
          sid: userInfo!["captcha_sid"] as! String,
          imageUrl: userInfo!["captcha_img"] as! String,
          request: request!)
      }
    case 17:
      request?.attempts--
      WebController.validate(request!, validationUrl: userInfo!["redirect_uri"] as! String)
    default:
      finaly()
    }
  }
  
  
  
  public func finaly() {
    if let realRequest = request {
      realRequest.reSend() == false
        ? {
          realRequest.isAPI ? Log([LogOption.error], "Executing error block") : ()
          realRequest.errorBlock(error: self)
          realRequest.isAPI ? Log([LogOption.error], "Executing error block is complete") : ()
          }()
        : ()
    }
  }
}

