import Foundation

internal var sharedCaptchaIsRun = false
internal var sharedCaptchaAnswer: [String : String]?


public final class Request {
    
    enum Raw {
        case api(method: String, parameters: [VK.Arg : String])
        case url(String)
        case upload(url: String, media: [Media])
    }
    
    public struct Callbacks {
        let onSuccess: VK.SuccessBlock?
        let onError: VK.ErrorBlock?
        let onProgress: VK.ProgressBlock?
        
        init(
            onSuccess: VK.SuccessBlock? = nil,
            onError: VK.ErrorBlock? = nil,
            onProgress: VK.ProgressBlock? = nil
            ) {
            self.onSuccess = onSuccess
            self.onError = onError
            self.onProgress = onProgress
        }
    }
    
    public struct Config {
        
        var timeout: TimeInterval
        var maxAttempts: Int
        var httpMethod: HttpMethod
        var catchErrors: Bool
        var logToConsole: Bool
        var next: ((JSON) -> Request)?
        
        init(
            timeout: TimeInterval = VK.config.timeOut,
            maxAttempts: Int = VK.config.maxAttempts,
            httpMethod: HttpMethod = .GET,
            catchErrors: Bool = VK.config.catchErrors,
            logToConsole: Bool = VK.config.logToConsole,
            next: ((JSON) -> Request)? = nil
            ) {
            self.timeout = timeout
            self.maxAttempts = maxAttempts
            self.httpMethod = httpMethod
            self.catchErrors = catchErrors
            self.logToConsole = logToConsole
            self.next = next
        }
    }
    
    
    let rawRequest: Raw
    public var config: Request.Config
    
    init(
        rawRequest: Raw,
        config: Request.Config
        ) {
        self.rawRequest = rawRequest
        self.config = config
    }
}


///HTTP prtocol methods. See - https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
public enum HttpMethod: String {
    case GET, POST
}
