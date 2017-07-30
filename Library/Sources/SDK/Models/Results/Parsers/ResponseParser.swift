import Foundation

class ResponseParser<Parser: SwiftyVkParser> {
    
    func parse(_ data: Data, with parser: Parser)
        -> Response<Parser.CustomResult, VkError<Parser.CustomError>> {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                
                if let apiError = ApiError(json) {
                    return .error(.api(apiError))
                }
                
                if let root = json as? [String: Any], let success = root["success"] {
                    let successData = try JSONSerialization.data(withJSONObject: success, options: [])
                    return convert(parser.parse(successData))
                }
                
                return convert(parser.parse(data))
            } catch let error {
                return .error(.request(.jsonNotParsed(error)))
            }
    }
    
    private func convert(_ data: Response<Parser.CustomResult, Parser.CustomError>)
        -> Response<Parser.CustomResult, VkError<Parser.CustomError>> {
            switch data {
            case let .success(result):
                return .success(result)
            case let .error(error):
                return .error(.custom(error))
            }
    }
}
