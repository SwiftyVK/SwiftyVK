import Foundation

private let boundary = "(======SwiftyVK======)"
private let methodUrl = "https://api.vk.com/method/"

protocol UrlRequestFactory {
    init()
    func make(from request: Request) throws -> URLRequest
}

struct UrlRequestFactoryImpl: UrlRequestFactory {

    func make(from request: Request) throws -> URLRequest {
        var urlRequest: URLRequest
        
        switch request.rawRequest {
        case .api(let method, let parameters):
            urlRequest = try make(from: method, parameters: parameters, httpMethod: request.config.httpMethod)
        case .upload(let url, let media):
            urlRequest = try make(from: media, url: url)
        case .url(let url):
            urlRequest = try make(from: url)
        }

        urlRequest.timeoutInterval = request.config.timeout

        return urlRequest
    }

    private func make(from url: String) throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw RequestError.wrongUrl
        }
        
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = "GET"
        return req
    }

    private func make(from apiMethod: String, parameters: Parameters, httpMethod: HttpMethod) throws
        -> URLRequest {
        var req: URLRequest
        
        let query = makeQuery(from: parameters)

        switch httpMethod {
        case .GET:
            req = try makeGetRequest(from: apiMethod, query: query)
        case .POST:
            req = try makePostRequest(from: apiMethod, query: query)
        }
        
        req.httpMethod = httpMethod.rawValue
        return req
    }
    
    private func makeGetRequest(from apiMethod: String, query: String) throws -> URLRequest {
        guard let url = URL(string: methodUrl + apiMethod + "?" + query) else {
            throw RequestError.wrongUrl
        }
        
        return URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
    }
    
    private func makePostRequest(from apiMethod: String, query: String) throws -> URLRequest {
        guard let url = URL(string: methodUrl + apiMethod) else {
            throw RequestError.wrongUrl
        }
        
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        
        let charset = String(
            CFStringConvertEncodingToIANACharSetName(
                CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)
            )
        )
        req.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
        req.httpBody = query.data(using: .utf8)
        return req
    }

    private func make(from media: [Media], url: String) throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw RequestError.wrongUrl
        }
        
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0)
        req.httpMethod = "POST"
        req.addValue("", forHTTPHeaderField: "Accept-Language")
        req.addValue("8bit", forHTTPHeaderField: "Content-Transfer-Encoding")
        req.setValue("multipart/form-data;  boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()

        for (index, file) in media.enumerated() {
            let name: String

            switch file {
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
    
    private func makeQuery(from parameters: Parameters) -> String {
        let paramArray = NSMutableArray()
        
        for (name, value) in parameters {
            guard let value = value else {
                continue
            }
            
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
