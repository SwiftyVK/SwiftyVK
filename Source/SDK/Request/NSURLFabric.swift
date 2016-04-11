import Foundation



private let boundary = "(======VK_SDK======)"
private let methodUrl = "https://api.vk.com/method/"



///NSURLRequest fabric
internal struct NSURLFabric {
  
  
  
  internal static func get(url url: String?, httpMethod: HTTPMethods, method: String, params: [String : String], media: [Media]?) -> NSMutableURLRequest {
    let result : NSMutableURLRequest!
    
    if let media = media {
      result = withFiles(media, url: url!)
    }
    else if let URL = url {
      result = withURL(URL)
    }
    else {
      result = withAPI(method, httpMethod: httpMethod, paramDictAsAnyObject: params as AnyObject)
    }
    
    return result
  }
  
  
  
  private static func withURL(url: String) -> NSMutableURLRequest {
    let req = NSMutableURLRequest(URL: NSURL(string: "")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
    req.HTTPMethod = "GET"
    req.URL = NSURL(string: url)
    return req
  }
  
  
  
  private static func withAPI(APIMethod: String, httpMethod: HTTPMethods, paramDictAsAnyObject: AnyObject) -> NSMutableURLRequest {
    let params = argToString(paramDictAsAnyObject as? [String : String])
    
    let req = NSMutableURLRequest(URL: NSURL(string: "")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
    req.HTTPMethod = httpMethod.rawValue

    if httpMethod == .GET {
      req.URL = NSURL(string: methodUrl + APIMethod + "?" + params)
    }
    else {
      req.URL = NSURL(string: methodUrl + APIMethod)
      let charset = String(CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)))
      req.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
      req.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    return req
  }
  
  
  
  private static func withFiles(media: [Media], url: String) -> NSMutableURLRequest {
    let req = NSMutableURLRequest(URL: NSURL(string: "")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
    req.HTTPMethod = "POST"
    req.URL = NSURL(string: url)
    req.addValue("", forHTTPHeaderField: "Accept-Language")
    req.addValue("8bit", forHTTPHeaderField: "Content-Transfer-Encoding")
    req.setValue("multipart/form-data;  boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    let body = NSMutableData()
    
    for (index, file) in media.enumerate() {
      let name : String
      
      switch file.mediaType {
      case .video:
        name = "video_file"
      case .audio, .document:
        name = "file"
      case .image:
        name = "file\(index)"
      }
      
      body.appendData("\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"; filename=\"file.\(file.type)\"\r\nContent-Type: document/other\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
      body.appendData(file.data)
    }
    body.appendData("\r\n--\(boundary)--\r".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    
    req.HTTPBody = body
    return req
  }
  
  
  
  private static func argToString(argDict: [String : String]?) -> String {
    let paramArray = NSMutableArray()
    
    if argDict == nil {return String()}
    
    for (argName, agrValue) in argDict! {
      paramArray.addObject("\(argName)=\(agrValue)")
    }
    return paramArray.componentsJoinedByString("&").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
  }
}
