import Foundation

protocol UrlRequestBuilder {
    func make(from request: Request.Raw, httpMethod: HttpMethod, config: Config, capthca: Captcha?)
        throws -> URLRequest
}

final class UrlRequestBuilderImpl: UrlRequestBuilder {
    
    private let baseUrl = "https://api.vk.com/method/"
    
    private let queryBuilder: QueryBuilder
    private let bodyBuilder: MultipartBodyBuilder
    
    init(
        queryBuilder: QueryBuilder,
        bodyBuilder: MultipartBodyBuilder
        ) {
        self.queryBuilder = queryBuilder
        self.bodyBuilder = bodyBuilder
    }
    
    func make(
        from request: Request.Raw,
        httpMethod: HttpMethod,
        config: Config,
        capthca: Captcha?
        )
        throws -> URLRequest
    {
        var urlRequest: URLRequest
        
        switch request {
        case .api(let method, let parameters):
            urlRequest = try make(
                from: method,
                parameters: parameters,
                httpMethod: httpMethod,
                config: config,
                capthca: capthca
            )
        case .upload(let url, let media, let partType):
            urlRequest = try make(from: media, url: url, partType: partType)
        case .url(let url):
            urlRequest = try make(from: url)
        }
        
        urlRequest.timeoutInterval = config.attemptTimeout
        
        return urlRequest
    }
    
    private func make(
        from apiMethod: String,
        parameters: Parameters,
        httpMethod: HttpMethod,
        config: Config,
        capthca: Captcha?
        ) throws -> URLRequest {
        var req: URLRequest
        
        let query = queryBuilder.makeQuery(from: parameters, config: config, captcha: capthca)
        
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
        guard let url = URL(string: baseUrl + apiMethod + "?" + query) else {
            throw RequestError.wrongUrl
        }
        
        return URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    private func makePostRequest(from apiMethod: String, query: String) throws -> URLRequest {
        guard let url = URL(string: baseUrl + apiMethod) else {
            throw RequestError.wrongUrl
        }
        
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        
        let charset = String(
            CFStringConvertEncodingToIANACharSetName(
                CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)
            )
        )
        
        req.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField: "Content-Type")
        req.httpBody = query.data(using: .utf8)
        
        return req
    }
    
    private func make(from media: [Media], url: String, partType: PartType) throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw RequestError.wrongUrl
        }
        
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        req.httpMethod = "POST"
        req.addValue("", forHTTPHeaderField: "Accept-Language")
        req.addValue("8bit", forHTTPHeaderField: "Content-Transfer-Encoding")
        req.setValue("multipart/form-data;  boundary=\(bodyBuilder.boundary)", forHTTPHeaderField: "Content-Type")
        req.httpBody = bodyBuilder.makeBody(from: media, partType: partType)
        
        return req
    }
    
    private func make(from url: String) throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw RequestError.wrongUrl
        }
        
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        req.httpMethod = "GET"
        
        return req
    }
}
