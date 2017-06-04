protocol Authorizator: class {
    func authorize(session: Session, revoke: Bool) throws -> Token
    func authorize(session: Session, rawToken: String, expires: TimeInterval) throws -> Token
    func validate(with url: URL) throws
    func reset(session: Session) -> Token?
    func handle(url: URL, app: String?)
}

final class AuthorizatorImpl: Authorizator {
    
    private let queue = DispatchQueue(label: "SwiftyVK.authorizatorQueue")
    private let webAuthorizeUrl = "https://oauth.vk.com/authorize?"
    private let webRedirectUrl = "https://oauth.vk.com/blank.html"
    
    private weak var delegate: SwiftyVKDelegate?
    private let appId: String
    private let tokenStorage: TokenStorage
    private let tokenMaker: TokenMaker
    private let tokenParser: TokenParser
    private let vkAppProxy: VkAppProxy
    private let webPresenterMaker: WebPresenterMaker
    private weak var currentWebPresenter: WebPresenter?
    
    private var handledToken: Token?
    
    init(
        appId: String,
        delegate: SwiftyVKDelegate?,
        tokenStorage: TokenStorage,
        tokenMaker: TokenMaker,
        tokenParser: TokenParser,
        vkAppProxy: VkAppProxy,
        webPresenterMaker: WebPresenterMaker
        ) {
        self.appId = appId
        self.delegate = delegate
        self.tokenStorage = tokenStorage
        self.tokenMaker = tokenMaker
        self.tokenParser = tokenParser
        self.vkAppProxy = vkAppProxy
        self.webPresenterMaker = webPresenterMaker
    }
    
    func authorize(session: Session, revoke: Bool) throws -> Token {
        guard !Thread.isMainThread else {
            assertionFailure("Never call this code from main thread!")
            throw SessionError.authCalledFromMainThread
        }
        
        return try queue.sync {
            
            defer {
                handledToken = nil
                currentWebPresenter = nil
            }
            
            if let token = tokenStorage.getFor(sessionId: session.id) {
                return token
            }
            
            let vkAppAuthQuery = try makeAuthQuery(session: session, redirectUrl: nil, revoke: revoke)
            
            if try vkAppProxy.send(query: vkAppAuthQuery) {
                Thread.sleep(forTimeInterval: 1)
            }
            
            guard let webPresenter = webPresenterMaker.webPresenter() else {
                throw SessionError.cantMakeWebViewController
            }
            
            currentWebPresenter = webPresenter
            
            let webAuthRequest = try makeWebAuthRequest(session: session, revoke: revoke)
            
            let token: Token
            
            do {
                let tokenInfo = try webPresenter.presentWith(urlRequest: webAuthRequest)
                token = try makeToken(from: tokenInfo)
            } catch let error {
                guard let handledToken = handledToken else {
                    throw error
                }
                
                token = handledToken
            }
            
            try tokenStorage.save(token: token, for:  session.id)
            return token
        }
    }
    
    private func makeAuthQuery(session: Session, redirectUrl: String?, revoke: Bool) throws -> String {
        
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
    
    private func makeWebAuthRequest(session: Session, revoke: Bool) throws -> URLRequest {
        let webQuery = try makeAuthQuery(
            session: session,
            redirectUrl: webRedirectUrl,
            revoke: revoke
        )
        
        guard let url = URL(string: webAuthorizeUrl + webQuery) else {
            throw SessionError.cantBuildUrlForWebView
        }
        
        return URLRequest(
            url: url,
            cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10
        )
    }
    
    private func makeToken(from tokenInfo: String) throws -> Token {
        guard let parsingResult = tokenParser.parse(tokenInfo: tokenInfo) else {
            throw SessionError.cantParseToken
        }
        
        return tokenMaker.token(
            token: parsingResult.token,
            expires: parsingResult.expires,
            info: parsingResult.info
        )
    }
    
    func authorize(session: Session, rawToken: String, expires: TimeInterval) throws -> Token {
        let token = tokenMaker.token(token: rawToken, expires: expires, info: [:])
        try tokenStorage.save(token: token, for:  session.id)
        return token
    }
    
    func validate(with url: URL) throws {
        
    }
    
    func reset(session: Session) -> Token? {
        tokenStorage.removeFor(sessionId: session.id)
        delegate?.vkDidLogOut(in: session)
        return nil
    }
    
    func handle(url: URL, app: String?) {
        guard
            let tokenInfo = vkAppProxy.handle(url: url, app: app),
            let handledToken = try? makeToken(from: tokenInfo) else
        {
            return
        }
        
        self.handledToken = handledToken
        currentWebPresenter?.dismiss()
    }
}
