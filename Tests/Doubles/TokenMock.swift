@testable import SwiftyVK

final class TokenMock: NSObject, Token {
    
    var token: String?
    let info: [String: String] = [:]
    
    init(token: String = "testToken") {
        self.token = token
    }
    
    init?(coder aDecoder: NSCoder) {
        token = aDecoder.decodeObject(forKey: "token") as? String ?? ""
    }
    
    func get() -> String? {
        return token
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(token, forKey: "token")
    }
}
