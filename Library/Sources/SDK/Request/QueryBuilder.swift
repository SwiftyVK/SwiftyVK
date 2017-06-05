typealias Captcha = (sid: String, key: String)

protocol QueryBuilder {
    func makeQuery(parameters: Parameters, config: Config, captcha: Captcha?, token: Token?) -> String
}

final class QueryBuilderImpl: QueryBuilder {
    
    func makeQuery(
        parameters: Parameters,
        config: Config = .default,
        captcha: Captcha? = nil,
        token: Token? = nil
        ) -> String {
        let paramArray = NSMutableArray()
        
        var rawParameters = [String: String]()
        
        for (name, value) in parameters {
            guard let value = value else { continue }
            rawParameters[name.rawValue] = value
        }
        
        rawParameters["v"] = config.apiVersion
        rawParameters["lang"] = config.language.rawValue
        rawParameters["https"] = "1"
        rawParameters["access_token"] = token?.get()
        
        if let captcha = captcha {
            rawParameters["captcha_sid"] = captcha.sid
            rawParameters["captcha_key"] = captcha.key
        }
        
        for (name, value) in rawParameters {
            if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryParametersAllowed) {
                paramArray.add("\(name)=\(encodedValue)")
            }
        }
        
        return paramArray.componentsJoined(by: "&")
    }
}
