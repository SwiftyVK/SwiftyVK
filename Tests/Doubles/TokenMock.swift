@testable import SwiftyVK

final class TokenMock: NSObject, Token {
    
    var token: String?
    let info: [String: String] = [:]
    
    override init() {}
    
    init?(coder aDecoder: NSCoder) {}
    
    func get() -> String? {
        return token
    }
    
    func encode(with aCoder: NSCoder) {}
}
