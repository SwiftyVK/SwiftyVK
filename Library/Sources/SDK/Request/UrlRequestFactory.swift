import Foundation

private let boundary = "(======SwiftyVK======)"
private let methodUrl = "https://api.vk.com/method/"

protocol UrlRequestFactory {
    init()
    func make(from request: Request) -> URLRequest
}

struct UrlRequestFactoryImpl: UrlRequestFactory {
    
    private var emptyUrl: URL {
        // swiftlint:disable force_unwrapping
        return URL(string: methodUrl)!
        // swiftlint:enable force_unwrapping
    }

    func make(from request: Request) -> URLRequest {
        var urlRequest: URLRequest
        
        switch request.rawRequest {
        case .api(let method, let parameters):
            urlRequest = make(from: method, parameters: parameters, httpMethod: request.config.httpMethod)
        case .upload(let url, let media):
            urlRequest = make(from: media, url: url)
        case .url(let url):
            urlRequest = make(from: url)
        }

        urlRequest.timeoutInterval = request.config.timeout

        return urlRequest
    }

    private func make(from url: String) -> URLRequest {
        var req = URLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = "GET"
        req.url = URL(string: url)
        return req
    }

    private func make(from apiMethod: String, parameters: [VK.Arg: String], httpMethod: HttpMethod) -> URLRequest {
        let query = makeQuery(from: parameters)

        var req = URLRequest(url: emptyUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = httpMethod.rawValue

        if httpMethod == .GET {
            req.url = URL(string: methodUrl + apiMethod + "?" + query)
        }
        else {
            req.url = URL(string: methodUrl + apiMethod)
            let charset = String(
                CFStringConvertEncodingToIANACharSetName(
                    CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)
                )
            )
            req.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
            req.httpBody = query.data(using: .utf8)
        }

        return req
    }

    private func make(from media: [Media], url: String) -> URLRequest {
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
            
            if let data = ("\r\n--\(boundary)\r\nContent-Disposition: form-data; name="
                + "\"\(name)\"; filename=\"file.\(file.type)\"\r\nContent-Type: document/other\r\n\r\n")
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
    
    private func makeQuery(from parameters: [VK.Arg : String]) -> String {
        let paramArray = NSMutableArray()
        
        for (name, value) in parameters {
            if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryParametersAllowed) {
                paramArray.add("\(name.rawValue)=\(encodedValue)")
            }
        }
        
        paramArray.add("v=\(VK.config.apiVersion)")
        paramArray.add("https=1")
        
        if let token = Token.get() {
            paramArray.add("access_token=\(token)")
        }
        
        if let lang = VK.config.language {
            paramArray.add("lang=\(lang)")
        }
        
        if let sid = sharedCaptchaAnswer?["captcha_sid"], let key = sharedCaptchaAnswer?["captcha_key"] {
            paramArray.add("captcha_sid=\(sid)")
            paramArray.add("captcha_key=\(key)")
            sharedCaptchaAnswer = nil
        }
        
        return paramArray.componentsJoined(by: "&")
    }
}
