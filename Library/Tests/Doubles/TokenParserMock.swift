@testable import SwiftyVK

final class TokenParserMock: TokenParser {
    
    var onParse: ((String) -> (token: String, expires: TimeInterval, info: [String : String])?)?
    
    func parse(tokenInfo: String) -> (token: String, expires: TimeInterval, info: [String : String])? {
        return onParse?(tokenInfo)
    }
}
