import Foundation



internal var sharedCaptchaIsRun = false
internal var sharedCaptchaAnswer : [String : String]?



///HTTP prtocol methods. See - https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
public enum HttpMethod : String {
    case GET, POST
}



public struct RequestConfig {
    ///Request timeout
    public var timeout = VK.config.timeOut
    ///Maximum number of attempts to send, after which execution priryvaetsya and an error is returned
    public var maxAttempts = VK.config.maxAttempts
    ///Whether to allow automatic processing of some API error
    public var catchErrors = VK.config.catchErrors
    ///Allows print log messages to console
    public var logToConsole : Bool = VK.config.logToConsole
    ///HTTP prtocol dending method. See - https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
    public var httpMethod = HttpMethod.GET
    
    public var parameters: [VK.Arg : String]
    
    internal private(set) var nextRequest: ((JSON) -> RequestConfig)?
    
    internal let method: String
    internal let customUrl: String
    internal let media: [VKMedia]
    internal var api: Bool {return !method.isEmpty}
    internal var upload: Bool {return !media.isEmpty && !customUrl.isEmpty && httpMethod == .POST}

    
    
    internal init(url: String) {
        self.customUrl      = url
        self.method         = ""
        self.parameters     = [:]
        self.media          = []
    }
    
    
    
    internal init(method: String, parameters: [VK.Arg : String] = [:]) {
        self.method         = method
        self.parameters     = parameters
        self.customUrl      = ""
        self.media          = []
    }
    
    
    
    internal init(url: String, media: [VKMedia]) {
        let dataLength      = TimeInterval(media.reduce(0) {return $0 + $1.data.count})
        self.method         = ""
        self.parameters     = [:]
        self.httpMethod     = .POST
        self.timeout        = dataLength*0.001
        self.customUrl      = url
        self.media          = media
    }
    
    
    
    @discardableResult public func send(
        onSuccess successBlock: VK.SuccessBlock? = nil,
        onError errorBlock:  VK.ErrorBlock? = nil,
        onProgress progressBlock:  VK.ProgressBlock? = nil
        ) -> RequestExecution {
        
        return RequestInstance.createWith(config: self, successBlock: successBlock, errorBlock: errorBlock, progressBlock: progressBlock)
    }
    
    
    
    public mutating func next(_ next: @escaping (_ response: JSON) -> RequestConfig) {
        nextRequest = next
    }
    
    
    public mutating func add(parameters: [VK.Arg : String]) {
        for (key, value) in parameters {
            self.parameters[key] = value
        }
    }
}
