import Foundation



private let boundary = "(======SwiftyVK======)"
private let methodUrl = "https://api.vk.com/method/"



///NSURLRequest fabric
internal struct UrlFabric {
    
    
    
    private static var emptyUrl: URL {
        // swiftlint:disable force_unwrapping
        return URL(string: methodUrl)!
        // swiftlint:enable force_unwrapping
    }



    internal static func createWith(config: RequestConfig) -> URLRequest {
        var request: URLRequest

        if config.upload {
            request = createWith(media: config.media, url: config.customUrl)
        }
        else if config.api {
            request = craeteWith(apiMethod: config.method, parameters: config.parameters, httpMethod: config.httpMethod)
        }
        else {
            request = createWith(url: config.customUrl)
        }

        request.timeoutInterval = config.timeout

        return request
    }



    private static func createWith(url: String) -> URLRequest {
        var req = URLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = "GET"
        req.url = URL(string: url)
        return req
    }



    private static func craeteWith(apiMethod: String, parameters: [VK.Arg: String], httpMethod: HttpMethod) -> URLRequest {
        let query = createQueryFrom(parameters: parameters)

        var req = URLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = httpMethod.rawValue

        if httpMethod == .GET {
            req.url = URL(string: methodUrl + apiMethod + "?" + query)
        }
        else {
            req.url = URL(string: methodUrl + apiMethod)
            let charset = String(CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)))
            req.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
            req.httpBody = query.data(using: .utf8)
        }

        return req
    }



    private static func createWith(media: [Media], url: String) -> URLRequest {
        var req = URLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = "POST"
        req.url = URL(string: url)
        req.addValue("", forHTTPHeaderField: "Accept-Language")
        req.addValue("8bit", forHTTPHeaderField: "Content-Transfer-Encoding")
        req.setValue("multipart/form-data;  boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()

        for (index, file) in media.enumerated() {
            let name: String

            switch file.mediaType {
            case .video:
                name = "video_file"
            case .audio, .document:
                name = "file"
            case .image:
                name = "file\(index)"
            }
            
            if let data = "\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"; filename=\"file.\(file.type)\"\r\nContent-Type: document/other\r\n\r\n"
                .data(using: .utf8, allowLossyConversion: false) {
                body.append(data)
            }

            body.append(file.data as Data)
        }
        
        if let data = "\r\n--\(boundary)--\r".data(using: .utf8, allowLossyConversion: false) {
            body.append(data)
        }

        req.httpBody = body as Data
        return req
    }
    
    
    
    private static func createQueryFrom(parameters: [VK.Arg : String]) -> String {
        var components = URLComponents()
        
        var queryItems = parameters.map {parameter -> URLQueryItem in
            URLQueryItem(name: parameter.key.rawValue, value: parameter.value)
        }
        
        queryItems.append(URLQueryItem(name: "v", value: "VK.config.apiVersion"))
        queryItems.append(URLQueryItem(name: "https", value: "1"))
        
        if let token = Token.get() {
            queryItems.append(URLQueryItem(name: "access_token", value: token))
            
        }
        
        if let lang = VK.config.language {
            queryItems.append(URLQueryItem(name: "lang", value: lang))
        }
        
        if let sid = sharedCaptchaAnswer?["captcha_sid"], let key = sharedCaptchaAnswer?["captcha_key"] {
            queryItems.append(URLQueryItem(name: "captcha_sid", value: sid))
            queryItems.append(URLQueryItem(name: "captcha_key", value: key))
            sharedCaptchaAnswer = nil
        }
        
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ""
    }
}
