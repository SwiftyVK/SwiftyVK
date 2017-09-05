@testable import SwiftyVK

class URLRequestBuilderMock: UrlRequestBuilder {
    
    var onBuild: (() throws -> URLRequest)?
    
    func build(request: RequestType, config: Config, capthca: Captcha?, token: Token?) throws -> URLRequest {
        return try onBuild?() ?? URLRequest(url: URL(string: "http://te.st")!)
    }
    
}
