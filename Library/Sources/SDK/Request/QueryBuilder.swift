typealias Captcha = (sid: String, key: String)

protocol QueryBuilder {
    func makeQuery(from parameters: Parameters, config: Config, captcha: Captcha?) -> String
}

final class QueryBuilderImpl: QueryBuilder {
    
    func makeQuery(from parameters: Parameters, config: Config = .default, captcha: Captcha? = nil) -> String {
        let paramArray = NSMutableArray()
        
        var rawParameters = [String: String]()
        
        for (name, value) in parameters {
            guard let value = value else { continue }
            rawParameters[name.rawValue] = value
        }
        
        rawParameters["v"] = SessionConfig.apiVersion
        rawParameters["lang"] = config.language.rawValue
        rawParameters["https"] = "1"
        
        if let token = LegacyToken.get() {
             rawParameters["access_token"] = token
        }
        
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
