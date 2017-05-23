protocol Authorizator: class {
    func authorize(session: Session) throws -> Token
    func authorize(session: Session, rawToken: String, expires: TimeInterval) -> Token
    func validate(with url: URL) throws
    func reset(session: Session) -> Token?
}

final class AuthorizatorImpl: Authorizator {

    private let tokenStorage: TokenStorage
    private let tokenMaker: TokenMaker
    
    init(tokenStorage: TokenStorage, tokenMaker: TokenMaker) {
        self.tokenStorage = tokenStorage
        self.tokenMaker = tokenMaker
    }
 
    func authorize(session: Session) throws -> Token {
        
        if let token = tokenStorage.getFor(sessionId: session.id) {
            return token
        } else {
            guard let scopes = VK.delegate?.vkWillLogIn(in: session) else {
                throw SessionError.delegateNotFound
            }
            
            let token = tokenMaker.token(token: "", expires: 0, info: [:])
            try tokenStorage.save(token: token, for:  session.id)
            return token
        }
    }
    
    func authorize(session: Session, rawToken: String, expires: TimeInterval) -> Token {
        return tokenMaker.token(token: rawToken, expires: expires, info: [:])
    }
    
    func validate(with url: URL) throws {
        
    }
    
    func reset(session: Session) -> Token? {
        tokenStorage.removeFor(sessionId: session.id)
        VK.delegate?.vkDidLogOut(in: session)
        return nil
    }
}
