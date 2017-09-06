import Foundation

protocol UrlRequestBuilder {
    func build(type: RequestType, config: Config, capthca: Captcha?, token: Token?)
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
    
    func build(
        type: RequestType,
        config: Config,
        capthca: Captcha?,
        token: Token?
        )
        throws -> URLRequest {
        var urlRequest: URLRequest
        
        switch type {
        case .api(let method, let parameters):
            urlRequest = try make(
                from: method,
                parameters: parameters,
                config: config,
                capthca: capthca,
                token: token
            )
        case .upload(let url, let media, let partType):
            urlRequest = try make(from: media, url: url, partType: partType)
        case .url(let url):
            urlRequest = try make(from: url)
        }
        
        urlRequest.timeoutInterval = config.attemptTimeout
        
        return urlRequest
    }
    
    // swiftlint:disable function_parameter_count next
    private func make(
        from apiMethod: String,
        parameters: Parameters,
        config: Config,
        capthca: Captcha?,
        token: Token?
        ) throws -> URLRequest {
        var req: URLRequest
        
        let query = queryBuilder.makeQuery(parameters: parameters, config: config, captcha: capthca, token: token)
        
        switch config.httpMethod {
        case .GET:
            req = try makeGetRequest(from: apiMethod, query: query)
        case .POST:
            req = try makePostRequest(from: apiMethod, query: query)
        }
        
        req.httpMethod = config.httpMethod.rawValue
        
        return req
    }
    
    private func makeGetRequest(from apiMethod: String, query: String) throws -> URLRequest {
        guard let url = URL(string: baseUrl + apiMethod + "?" + query) else {
            throw VKError.wrongUrl
        }
        
        return URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    private func makePostRequest(from apiMethod: String, query: String) throws -> URLRequest {
        guard let url = URL(string: baseUrl + apiMethod) else {
            throw VKError.wrongUrl
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
            throw VKError.wrongUrl
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
            throw VKError.wrongUrl
        }
        
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        req.httpMethod = "GET"
        
        return req
    }
}
