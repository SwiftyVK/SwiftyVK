import Foundation



internal var sharedCaptchaIsRun = false
internal var sharedCaptchaAnswer: [String : String]?



///HTTP prtocol methods. See - https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
public enum HttpMethod: String {
    case GET, POST
}



public struct RequestConfig {
    ///Request timeout
    public var timeout = VK.config.timeOut
    ///Maximum number of attempts to send, after which execution priryvaetsya and an error is returned
    public var maxAttempts = VK.config.maxAttempts
    ///HTTP prtocol dending method. See - https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
    public var httpMethod = HttpMethod.GET
    ///Request API parameters
    public var parameters: [VK.Arg : String]
    ///Whether to allow automatic processing of some API error
    public var catchErrors = VK.config.catchErrors
    ///Allows print log messages on this request to console
    public var logToConsole: Bool = VK.config.logToConsole
    
    internal var handleProgress = true

    internal private(set) var nextRequest: ((JSON) -> RequestConfig)?

    internal let method: String
    internal let customUrl: String
    internal let media: [Media]
    internal var api: Bool {return !method.isEmpty}
    internal var upload: Bool {return !media.isEmpty && !customUrl.isEmpty && httpMethod == .POST}



    internal init(url: String) {
        self.customUrl      = url
        self.method         = ""
        self.parameters     = [:]
        self.media          = []
    }



    internal init(method: String, parameters: [VK.Arg : String] = [:], handleProgress: Bool = true) {
        self.method         = method
        self.parameters     = parameters
        self.customUrl      = ""
        self.media          = []
        self.handleProgress = handleProgress
    }



    internal init(url: String, media: [Media]) {
        let dataLength      = TimeInterval(media.reduce(0) {return $0 + $1.data.count})
        self.method         = ""
        self.parameters     = [:]
        self.httpMethod     = .POST
        self.timeout        = dataLength*0.001
        self.customUrl      = url
        self.media          = media
    }


    
    /// Send request to VK
    ///
    /// - Parameters:
    ///   - successBlock: called when request receive valid response
    ///   - errorBlock: called when request receive error
    ///   - progressBlock: called when part of data transfereed to server
    /// - Returns: instance of RequestExecution
    @discardableResult
    public func send(
        onSuccess successBlock: VK.SuccessBlock? = nil,
        onError errorBlock: VK.ErrorBlock? = nil,
        onProgress progressBlock: VK.ProgressBlock? = nil
        ) -> RequestExecution? {
        
        if VK.state < .configured {
            errorBlock?(RequestError.notConfigured)
            return nil
        }

        return RequestInstance.createWith(config: self, successBlock: successBlock, errorBlock: errorBlock, progressBlock: progressBlock)
    }


    
    /// Add a request that will be sent after the request will receive a valid response
    ///
    /// - Parameter next: block of code, which should return the next query
    /// - Parameter response: response of this request
    public mutating func next(_ next: @escaping (_ response: JSON) -> RequestConfig) {
        nextRequest = next
    }
    
    
    
    /// Add ned request parameters
    ///
    /// - Parameter parameters: new request parameters
    public mutating func add(parameters: [VK.Arg : String]) {
        for (key, value) in parameters {
            self.parameters[key] = value
        }
    }
}
