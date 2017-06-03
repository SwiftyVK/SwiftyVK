protocol Authorizator: class {
    func authorize(session: Session, revoke: Bool) throws -> Token
    func authorize(session: Session, rawToken: String, expires: TimeInterval) -> Token
    func validate(with url: URL) throws
    func reset(session: Session) -> Token?
}

final class AuthorizatorImpl: Authorizator {
    
    private let queue = DispatchQueue(label: "SwiftyVK.authorizatorQueue")
    private let redirectUrl = "https://oauth.vk.com/blank.html"
    private let webAuthorizeUrl = "https://oauth.vk.com/authorize?"
    
    private weak var delegate: SwiftyVKDelegate?
    private let appId: String
    private let tokenStorage: TokenStorage
    private let tokenMaker: TokenMaker
    private let vkAppProxy: VkAppProxy
    
    init(
        appId: String,
        delegate: SwiftyVKDelegate?,
        tokenStorage: TokenStorage,
        tokenMaker: TokenMaker,
        vkAppProxy: VkAppProxy
        ) {
        self.appId = appId
        self.tokenStorage = tokenStorage
        self.tokenMaker = tokenMaker
        self.vkAppProxy = vkAppProxy
    }
    
    func authorize(session: Session, revoke: Bool) throws -> Token {
        guard !Thread.isMainThread else {
            assertionFailure("Never call this code from main thread!")
            throw SessionError.authCalledFromMainThread
        }
        
        return try queue.sync {
            if let token = tokenStorage.getFor(sessionId: session.id) {
                return token
            }
            
            try vkAppProxy.authorizeWith(
                query: makeAuthQuery(session: session, redirectUrl: nil, revoke: revoke)
            )
            
            Thread.sleep(forTimeInterval: 1)
            
            let token = tokenMaker.token(token: "", expires: 0, info: [:])
            try tokenStorage.save(token: token, for:  session.id)
            return token
        }
    }
    
    func makeAuthQuery(session: Session, redirectUrl: String?, revoke: Bool) throws -> String {
        
        guard let scopes = delegate?.vkWillLogIn(in: session).toInt() else {
            throw SessionError.delegateNotFound
        }
        
        let redirect: String
        
        if let url = redirectUrl, !url.isEmpty {
            redirect = "&redirect_uri=\(url)"
        } else {
            redirect = ""
        }
        
        return "client_id=\(appId)&"
            + "scope=\(scopes)&"
            + "display=mobile&"
            + "v\(session.config.apiVersion)&"
            + "sdk_version=\(session.config.sdkVersion)"
            + "\(redirect)&"
            + "response_type=token&"
            + "revoke=\(revoke ? 1 : 0)"
    }
    
    func authorize(session: Session, rawToken: String, expires: TimeInterval) -> Token {
        return tokenMaker.token(token: rawToken, expires: expires, info: [:])
    }
    
    func validate(with url: URL) throws {
        
    }
    
    func reset(session: Session) -> Token? {
        tokenStorage.removeFor(sessionId: session.id)
        delegate?.vkDidLogOut(in: session)
        return nil
    }
}
