import Foundation



public final class VKError : Error, CustomStringConvertible {
    public private(set) var domain : String
    public private(set) var code: Int
    public private(set) var reason : String
    public private(set) var userInfo : [AnyHashable: Any]?
    public private(set) var request : Request?
    
    public var description : String {
        return "<VKError \(domain)(\(code)): \(reason)>"
    }
    
    
    
    internal init(error: NSError, request: Request?) {
        self.domain = error.domain
        self.code = error.code
        self.reason = error.localizedDescription
        self.request = request
        
        if let request = request {
            VK.Log.put(request, "Init \(self) from NSError")
        }
    }
    
    
    
    internal init(code: Int, desc: String, request: Request?) {
        self.domain = "SwiftyVKDomain"
        self.code = code
        self.reason = desc
        self.request = request
        
        if let request = request {
            VK.Log.put(request, "Init custom \(self)")
        }
    }
    
    
    
    internal init(json : JSON, request : Request) {
        self.request = request
        domain = "APIDomain"
        code = json["error_code"].intValue
        reason = json["error_msg"].stringValue
        var info = [AnyHashable : Any]()
        
        for param in json["request_params"].arrayValue {
            info[param["key"].stringValue] = param["value"].stringValue
        }
        
        for (key, value) in json.dictionaryValue {
            if key != "request_params" && key != "error_code" {
                info[key] = value.stringValue
            }
        }
        
        userInfo = info
        
        VK.Log.put(request, "Init \(self) from JSON response")
    }
    
    
    
    public func solve() {
        if let request = request {
            VK.Log.put(request, "Catch error \(self)")
        }
        
        switch self.domain {
        case "APIDomain":
            solveAPIDomain()
        default:
            finaly()
        }
    }
    
    
    
    private func solveAPIDomain() {
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

