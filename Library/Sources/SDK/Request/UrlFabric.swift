import Foundation



private let boundary = "(======SwiftyVK======)"
private let methodUrl = "https://api.vk.com/method/"



///NSURLRequest fabric
internal struct UrlFabric {
    
    
    
    internal static func createWith(config: RequestConfig) -> URLRequest {
        let result : NSMutableURLRequest
        
        if config.upload {
            result = createWith(media: config.media, url: config.customUrl)
        }
        else if config.api {
            result = craeteWith(apiMethod: config.method, parameters: config.parameters, httpMethod: config.httpMethod)
        }
        else {
            result = createWith(url: config.customUrl)
        }
        
        result.timeoutInterval = config.timeout
        
        return result as URLRequest
    }
    
    
    
    private static func createWith(url: String) -> NSMutableURLRequest {
        let emptyUrl = URL(string: methodUrl)!
        
        let req = NSMutableURLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = "GET"
        req.url = URL(string: url)
        return req
    }
    
    
    
    private static func craeteWith(apiMethod: String, parameters: [VK.Arg: String], httpMethod: HttpMethod) -> NSMutableURLRequest {
        let paramStr = stringFrom(parameters: parameters)
        let emptyUrl = URL(string: methodUrl)!
        
        let req = NSMutableURLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = httpMethod.rawValue
        
        if httpMethod == .GET {
            req.url = URL(string: methodUrl + apiMethod + "?" + paramStr)
        }
        else {
            req.url = URL(string: methodUrl + apiMethod)
            let charset = String(CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)))
            req.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
            req.httpBody = paramStr.data(using: .utf8)
        }
        
        return req
    }
    
    
    
    private static func createWith(media: [Media], url: String) -> NSMutableURLRequest {
        let emptyUrl = URL(string: methodUrl)!
        
        let req = NSMutableURLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = "POST"
        req.url = URL(string: url)
        req.addValue("", forHTTPHeaderField: "Accept-Language")
        req.addValue("8bit", forHTTPHeaderField: "Content-Transfer-Encoding")
        req.setValue("multipart/form-data;  boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()
        
        for (index, file) in media.enumerated() {
            let name : String
            
            switch file.mediaType {
            case .video:
                name = "video_file"
            case .audio, .document:
                name = "file"
            case .image:
                name = "file\(index)"
            }
            
            body.append("\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"; filename=\"file.\(file.type)\"\r\nContent-Type: document/other\r\n\r\n".data(using: .utf8, allowLossyConversion: false)!)
            body.append(file.data as Data)
        }
        body.append("\r\n--\(boundary)--\r".data(using: .utf8, allowLossyConversion: false)!)
        
        req.httpBody = body as Data
        return req
    }

    
    
    private static func stringFrom(parameters: [VK.Arg : String]) -> String {
        let paramArray = NSMutableArray()
        
        for (name, value) in parameters {
            paramArray.add("\(name.rawValue)=\(value)")
        }
        
        paramArray.add("v=\(VK.config.apiVersion)")
        paramArray.add("https=1")
        
        if let token = Token.get() {
            paramArray.add("access_token=\(token)")
        }
        
        if let lang = VK.config.language {
            paramArray.add("lang=\(lang)")
        }
        
        if sharedCaptchaAnswer != nil {
            paramArray.add("captcha_sid=\(sharedCaptchaAnswer!["captcha_sid"])")
            paramArray.add("captcha_key=\(sharedCaptchaAnswer!["captcha_key"])")
            sharedCaptchaAnswer = nil
        }
    
        return paramArray.componentsJoined(by: "&").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}
