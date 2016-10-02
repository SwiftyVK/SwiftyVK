import Foundation



private let boundary = "(======SwiftyVK======)"
private let methodUrl = "https://api.vk.com/method/"



///NSURLRequest fabric
internal struct NSURLFabric {
    
    
    
    internal static func get(url: String?, httpMethod: HTTPMethods, method: String, params: [String : String], VKMedia: [VKMedia]?) -> NSMutableURLRequest {
        let result : NSMutableURLRequest
        
        if let VKMedia = VKMedia {
            result = withFiles(VKMedia, url: url!)
        }
        else if let URL = url {
            result = withURL(URL)
        }
        else {
            result = withAPI(method, httpMethod: httpMethod, paramDictAsAnyObject: params as AnyObject)
        }
        
        return result
    }
    
    
    
    private static func withURL(_ url: String) -> NSMutableURLRequest {
        let emptyUrl = URL(string: methodUrl)!
        
        let req = NSMutableURLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = "GET"
        req.url = URL(string: url)
        return req
    }
    
    
    
    private static func withAPI(_ APIMethod: String, httpMethod: HTTPMethods, paramDictAsAnyObject: AnyObject) -> NSMutableURLRequest {
        let params = argToString(paramDictAsAnyObject as? [String : String])
        let emptyUrl = URL(string: methodUrl)!
        
        let req = NSMutableURLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = httpMethod.rawValue
        
        if httpMethod == .GET {
            req.url = URL(string: methodUrl + APIMethod + "?" + params)
        }
        else {
            req.url = URL(string: methodUrl + APIMethod)
            let charset = String(CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)))
            req.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
            req.httpBody = params.data(using: .utf8)
        }
        
        return req
    }
    
    
    
    private static func withFiles(_ VKMedia: [VKMedia], url: String) -> NSMutableURLRequest {
        let emptyUrl = URL(string: methodUrl)!
        
        let req = NSMutableURLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = "POST"
        req.url = URL(string: url)
        req.addValue("", forHTTPHeaderField: "Accept-Language")
        req.addValue("8bit", forHTTPHeaderField: "Content-Transfer-Encoding")
        req.setValue("multipart/form-data;  boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()
        
        for (index, file) in VKMedia.enumerated() {
            let name : String
            
            switch file.mediaType {
            case .video:
                name = "video_file"
            case .audio, .document:
                name = "file"
            case .image:
                name = "file\(index)"
            }
            
            body.append("\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"; filename=\"file.\(file.type)\"\r\nContent-Type: document/other\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            body.append(file.data as Data)
        }
        body.append("\r\n--\(boundary)--\r".data(using: .utf8, allowLossyConversion: false)!)
        
        req.httpBody = body as Data
        return req
    }
    
    
    
    private static func argToString(_ argDict: [String : String]?) -> String {
        let paramArray = NSMutableArray()
        
        if argDict == nil {return String()}
        
        for (argName, agrValue) in argDict! {
            paramArray.add("\(argName)=\(agrValue)")
        }
        return paramArray.componentsJoined(by: "&").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}
