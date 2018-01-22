import Foundation

typealias Captcha = (sid: String, key: String)

protocol QueryBuilder {
    func makeQuery(parameters: RawParameters, config: Config, captcha: Captcha?, token: Token?) -> String
}

final class QueryBuilderImpl: QueryBuilder {
    
    func makeQuery(
        parameters: RawParameters,
        config: Config = .default,
        captcha: Captcha? = nil,
        token: Token? = nil
        ) -> String {
        let paramArray = NSMutableArray()
        
        var rawParameters = RawParameters()
        
        rawParameters["captcha_sid"] = captcha?.sid
        rawParameters["captcha_key"] = captcha?.key
        
        for (key, value) in parameters where !value.isEmpty {
            rawParameters[key] = value
        }
        
        rawParameters["https"] = "1"
        rawParameters["v"] = config.apiVersion
        rawParameters["lang"] = config.language.rawValue
        rawParameters["access_token"] = token?.get()
        
        for (name, value) in rawParameters {
            if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryParametersAllowed) {
                paramArray.add("\(name)=\(encodedValue)")
            }
        }
        
        return paramArray.componentsJoined(by: "&")
    }
}
