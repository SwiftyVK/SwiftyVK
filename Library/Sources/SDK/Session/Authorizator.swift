protocol Authorizator: class {
    func authorizeWith(scopes: Scopes) throws -> Token
    func authorizeWith(rawToken: String, expires: TimeInterval) -> Token
    func validate(withUrl url: String) throws
}

final class AuthorizatorImpl: Authorizator {
    
    private let redirectUrl = "https://oauth.vk.com/blank.html"
    private let webAuthorizeUrl = "https://oauth.vk.com/authorize?"
    private let appAuthorizeUrl = "vkauthorize://authorize?"
    
    private let tokenMaker: TokenMaker
    
    init(tokenMaker: TokenMaker) {
        self.tokenMaker = tokenMaker
    }
 
    func authorizeWith(scopes: Scopes) throws -> Token {
        throw SessionError.failedAuthorization
    }
    
    func authorizeWith(rawToken: String, expires: TimeInterval) -> Token {
        return tokenMaker.token(token: rawToken, expires: expires, info: [:])
    }
    
    func validate(withUrl url: String) throws {
        
    }
}
