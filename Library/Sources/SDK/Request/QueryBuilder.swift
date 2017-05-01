typealias Captcha = (sid: String, key: String)

protocol QueryBuilder {
    func makeQuery(from parameters: Parameters, captcha: Captcha?) -> String
}

final class QueryBuilderImpl: QueryBuilder {
    
    func makeQuery(from parameters: Parameters, captcha: Captcha? = nil) -> String {
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
        
        if let captcha = captcha {
            paramArray.add("captcha_sid=\(captcha.sid)")
            paramArray.add("captcha_key=\(captcha.key)")
        }
        
        return paramArray.componentsJoined(by: "&")
    }
}
