import Foundation



private let boundary = "(======VK_SDK======)"
private let methodUrl = "https://api.vk.com/method/"



///NSURLRequest fabric
internal struct NSURLFabric {
  
  
  
  internal static func get(url url: String?, HTTPMethod: String?, method: String, params: [String : String], media: [Media]?) -> NSMutableURLRequest {
    let result : NSMutableURLRequest!
    
    if let media = media {
      result = withFiles(media, url: url!)
    }
    else if let URL = url {
      result = withURL(URL)
    }
    else {
      result = withAPI(method, HTTPMethod: HTTPMethod!, paramDictAsAnyObject: params as AnyObject)
    }
    
    return result
  }
  
  
  
  private static func withURL(url : String) -> NSMutableURLRequest {
    Log([.urlReq], "Create URL requst with url \(url)")
    let req = NSMutableURLRequest(URL: NSURL(string: "")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
    req.URL = NSURL(string: url)
    req.HTTPMethod = "GET"
    return req
  }
  
  
  
  private static func withAPI(APIMethod: String, HTTPMethod: String, paramDictAsAnyObject: AnyObject) -> NSMutableURLRequest {
    Log([.urlReq], "Create URL requst with method \(APIMethod)")
    let req = NSMutableURLRequest(URL: NSURL(string: "")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
    req.URL = NSURL(string: methodUrl + APIMethod + "?" + argToString(paramDictAsAnyObject as? [String : String]))
    req.HTTPMethod = HTTPMethod
    return req
  }
  
  
  
  private static func withFiles(media: [Media], url: String) -> NSMutableURLRequest {
    Log([.urlReq], "Create URL requst with files \(media)")
    let req = NSMutableURLRequest(URL: NSURL(string: "")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
    req.URL = NSURL(string: url)
    req.HTTPMethod = "POST"
    req.addValue("", forHTTPHeaderField: "Accept-Language")
    req.addValue("8bit", forHTTPHeaderField: "Content-Transfer-Encoding")
    req.setValue("multipart/form-data;  boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    let body = NSMutableData()
    Log([.createHTTP], "Create HTTP body")
    
    for (index, file) in media.enumerate() {
      Log([.createHTTP], "Add file \(index) to HTTP body")
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
    Log([.createHTTP], "Create HTTP is completed")
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
