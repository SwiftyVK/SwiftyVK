protocol Authorizator: class {
    func set(session: Session)
    func authorize() throws
    func authorizeWith(rawToken: String, expiresIn: Int)
    func validate(withUrl url: String) throws
}

final class AuthorizatorImpl: Authorizator {
    
    private let redirectUrl = "https://oauth.vk.com/blank.html"
    private let webAuthorizeUrl = "https://oauth.vk.com/authorize?"
    private let appAuthorizeUrl = "vkauthorize://authorize?"
    
    private weak var session: Session?
    private let tokenMaker: TokenMaker
    
    init(tokenMaker: TokenMaker) {
        self.tokenMaker = tokenMaker
    }
    
    func set(session: Session) {
        self.session = session
    }
 
    func authorize() throws {
        
    }
    
    func authorizeWith(rawToken: String, expiresIn: Int) {
        
    }
    
    func validate(withUrl url: String) throws {
        
    }
}
