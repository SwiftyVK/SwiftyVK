protocol Authorizator: class {
    func authorize(sessionId: String, config: SessionConfig, revoke: Bool) throws -> Token
    func authorize(sessionId: String, rawToken: String, expires: TimeInterval) throws -> Token
    func validate(sessionId: String, url: URL) throws -> Token
    func reset(sessionId: String) -> Token?
    func handle(url: URL, app: String?)
}

final class AuthorizatorImpl: Authorizator {
    
    private let queue = DispatchQueue(label: "SwiftyVK.authorizatorQueue")
    private let webAuthorizeUrl = "https://oauth.vk.com/authorize?"
    private let webRedirectUrl = "https://oauth.vk.com/blank.html"
    
    private let appId: String
    private let tokenStorage: TokenStorage
    private let tokenMaker: TokenMaker
    private let tokenParser: TokenParser
    private let vkAppProxy: VkAppProxy
    private let webPresenter: WebPresenter
    private weak var delegate: SwiftyVKDelegate?    
    
    private(set) var handledToken: Token?
    private var requestTimeout: TimeInterval = 10
    
    init(
        appId: String,
        delegate: SwiftyVKDelegate?,
        tokenStorage: TokenStorage,
        tokenMaker: TokenMaker,
        tokenParser: TokenParser,
        vkAppProxy: VkAppProxy,
        webPresenter: WebPresenter
        ) {
        self.appId = appId
        self.delegate = delegate
        self.tokenStorage = tokenStorage
        self.tokenMaker = tokenMaker
        self.tokenParser = tokenParser
        self.vkAppProxy = vkAppProxy
        self.webPresenter = webPresenter
    }
    
    func authorize(sessionId: String, config: SessionConfig, revoke: Bool) throws -> Token {
        return try queue.sync {
            if let token = tokenStorage.getFor(sessionId: sessionId) {
                return token
            }
            
            guard let scopes = delegate?.vkNeedsScopes(for: sessionId).toInt() else {
                throw SessionError.delegateNotFound
            }
            
            let vkAppAuthQuery = try makeAuthQuery(
                sessionId: sessionId,
                config: config,
                scopes: scopes,
                redirectUrl: nil,
                revoke: revoke
            )
            
            if try vkAppProxy.send(query: vkAppAuthQuery) {
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            let webAuthRequest = try makeWebAuthRequest(
                sessionId: sessionId,
                config: config,
                scopes: scopes,
                revoke: revoke
            )
            
            return try getToken(sessionId: sessionId, request: webAuthRequest)
        }
    }
    
    func authorize(sessionId: String, rawToken: String, expires: TimeInterval) throws -> Token {
        return try queue.sync {
            let token = tokenMaker.token(token: rawToken, expires: expires, info: [:])
            try tokenStorage.save(token: token, for:  sessionId)
            delegate?.vkTokenUpdated(for: sessionId, info: [:])
            return token
        }
    }
    
    func validate(sessionId: String, url: URL) throws -> Token {
        return try queue.sync {
            let validationRequest = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: requestTimeout
            )
            
            return try getToken(sessionId: sessionId, request: validationRequest)
        }
    }
    
    func reset(sessionId: String) -> Token? {
        return queue.sync {
            tokenStorage.removeFor(sessionId: sessionId)
            delegate?.vkDidLogOut(for: sessionId)
            return nil
        }
    }
    
    func handle(url: URL, app: String?) {
        guard
            let tokenInfo = vkAppProxy.handle(url: url, app: app),
            let handledToken = try? makeToken(tokenInfo: tokenInfo) else
        {
            return
        }
        
        self.handledToken = handledToken
        webPresenter.dismiss()
    }
    
    private func getToken(sessionId: String, request: URLRequest) throws -> Token {
        defer {
            handledToken = nil
            webPresenter.dismiss()
        }
        
        let token: Token
        
        do {
            let tokenInfo = try webPresenter.presentWith(urlRequest: request)
            token = try makeToken(tokenInfo: tokenInfo)
        } catch let error {
            guard let handledToken = handledToken else {
                throw error
            }
            
            token = handledToken
        }
        
        try tokenStorage.save(token: token, for:  sessionId)
        delegate?.vkTokenUpdated(for: sessionId, info: token.info)
        return token
    }
    
    private func makeToken(tokenInfo: String) throws -> Token {
        guard let parsingResult = tokenParser.parse(tokenInfo: tokenInfo) else {
            throw SessionError.cantParseToken
        }
        
        return tokenMaker.token(
            token: parsingResult.token,
            expires: parsingResult.expires,
            info: parsingResult.info
        )
    }
    
    private func makeWebAuthRequest(
        sessionId: String,
        config: SessionConfig,
        scopes: Int,
        revoke: Bool
        ) throws -> URLRequest {
        let webQuery = try makeAuthQuery(
            sessionId: sessionId,
            config: config,
            scopes: scopes,
            redirectUrl: webRedirectUrl,
            revoke: revoke
        )
        
        guard let url = URL(string: webAuthorizeUrl + webQuery) else {
            throw SessionError.cantBuildUrlForWebView
        }
        
        return URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: requestTimeout
        )
    }
    
    private func makeAuthQuery(
        sessionId: String,
        config: SessionConfig,
        scopes: Int,
        redirectUrl: String?,
        revoke: Bool
        ) throws -> String {
        let redirect: String
        
        if let url = redirectUrl, !url.isEmpty {
            redirect = "&redirect_uri=\(url)"
        } else {
            redirect = ""
        }
        
        return "client_id=\(appId)&"
            + "scope=\(scopes)&"
            + "display=mobile&"
            + "v\(config.apiVersion)&"
            + "sdk_version=\(config.sdkVersion)"
            + "\(redirect)&"
            + "response_type=token&"
            + "revoke=\(revoke ? 1 : 0)"
    }
}
