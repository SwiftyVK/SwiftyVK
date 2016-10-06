import Foundation



internal var sharedCaptchaIsRun = false
internal var sharedCaptchaAnswer : [String : String]?



///HTTP prtocol methods. See - https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
public enum HTTPMethods : String {
    case GET, POST
}



///Request to VK API
public final class Request {
    ///Request timeout
    public var timeout = VK.defaults.timeOut
    ///Maximum number of attempts to send, after which execution priryvaetsya and an error is returned
    public var maxAttempts = VK.defaults.maxAttempts
    ///Whether to allow automatic processing of some API error
    public var catchErrors = VK.defaults.catchErrors
    ///Allows print log messages to console
    public var logToConsole : Bool = VK.defaults.logToConsole
    ///HTTP prtocol dending method. See - https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
    public var httpMethod = HTTPMethods.GET
    internal var method = ""
    internal private(set) var isAPI = false
    internal var swappedRequest : Request? = nil
    internal var customURL : String? = nil
    private var media : [VKMedia]?
    fileprivate var parameters = [String : String]()
    
    public var successBlock : VK.SuccessBlock {
        get{return privateSuccessBlock}
        set{
            if swappedRequest != nil {swappedRequest?.successBlock = newValue}
            else {privateSuccessBlock = newValue}
        }
    }
    private var privateSuccessBlock = VK.defaults.successBlock
    public var errorBlock = VK.defaults.errorBlock
    public var progressBlock = VK.defaults.progressBlock
    public var language : String? {
        get {
            return privateLanguage ?? VK.defaults.language
        }
        set {
            guard let newValue = newValue, VK.defaults.supportedLanguages.contains(newValue) else {return}
            self.privateLanguage = newValue
        }
    }
    private var privateLanguage : String?
    internal var urlRequest : URLRequest {
        let req = NSURLFabric.get(url: customURL, httpMethod: httpMethod, method: method, params: allParameters, media: media)
        req.timeoutInterval = TimeInterval(self.timeout)
        return req as URLRequest
    }
    private var allParameters : [String : String] {
        var params = parameters
        
        if let token = Token.get() {
            params["access_token"] = token
        }
        
        if sharedCaptchaAnswer != nil {
            params["captcha_sid"] = sharedCaptchaAnswer!["captcha_sid"]
            params["captcha_key"] = sharedCaptchaAnswer!["captcha_key"]
            sharedCaptchaAnswer = nil
        }
        
        params["v"] = VK.defaults.apiVersion
        params["https"] = "1";
        
        if let lang = language {
            params["lang"] = lang
        }
        
        return params
    }
    
    
    
    internal init() {}
    
    
    
    internal init(url: String) {
        self.customURL = url
    }
    
    
    
    internal init(method: String, parameters: [VK.Arg : String] = [:]) {
        self.isAPI               = true
        self.method              = method
        self.parameters          = argToString(parameters)
    }
    
    
    
    internal init(url: String, media: [VKMedia]) {
        var length = Double(0)
        media.forEach {length += Double($0.data.count)}
        
        self.httpMethod          = .POST
        self.timeout             = Int(length*0.0001)
        self.customURL           = url
        self.media             = media
    }
    
    
    
    ///Add new parameters to request
    public func addParameters(_ agrDict: [VK.Arg : String]?) {
        for (argName, argValue) in agrDict! {
            self.parameters[argName.rawValue] = argValue
        }
    }
    
    
    
    ///Sending request. All parameters are optional
    @discardableResult public func send(
        method httpMethod: HTTPMethods? = nil,
        onSuccess successBlock: VK.SuccessBlock? = nil,
        onError errorBlock:  VK.ErrorBlock? = nil) -> RequestPointer {
        
        self.httpMethod = httpMethod ?? self.httpMethod
        self.successBlock = successBlock ?? self.successBlock
        self.errorBlock = errorBlock ?? self.errorBlock
        
        return RequestInstance.createWith(request: self)
    }
    
    
    
    private func argToString(_ agrDict: [VK.Arg : String]?) -> [String : String] {
        var strDict = [String : String]()
        
        guard agrDict != nil else {return [:]}
        
        for (argName, argValue) in agrDict! {
            strDict[argName.rawValue] = argValue
        }
        return strDict
    }
}

