protocol Authorizator: class {
    func getSavedToken(sessionId: String) -> Token?
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
    private let vkAppProxy: VKAppProxy
    private let webPresenter: WebPresenter
    private let cookiesHolder: CookiesHolder?
    private weak var delegate: SwiftyVKAuthorizatorDelegate?
    
    private(set) var handledToken: Token?
    private var requestTimeout: TimeInterval = 10
    
    init(
        appId: String,
        delegate: SwiftyVKAuthorizatorDelegate?,
        tokenStorage: TokenStorage,
        tokenMaker: TokenMaker,
        tokenParser: TokenParser,
        vkAppProxy: VKAppProxy,
        webPresenter: WebPresenter,
        cookiesHolder: CookiesHolder?
        ) {
        self.appId = appId
        self.delegate = delegate
        self.tokenStorage = tokenStorage
        self.tokenMaker = tokenMaker
        self.tokenParser = tokenParser
        self.vkAppProxy = vkAppProxy
        self.webPresenter = webPresenter
        self.cookiesHolder = cookiesHolder
    }
    
    func authorize(sessionId: String, config: SessionConfig, revoke: Bool) throws -> Token {
        return try queue.sync {
            if let token = getSavedToken(sessionId: sessionId) {
                return token
            }
            
            guard let scopes = delegate?.vkNeedsScopes(for: sessionId).rawValue else {
                throw VKError.vkDelegateNotFound
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
    
    func getSavedToken(sessionId: String) -> Token? {
        return tokenStorage.getFor(sessionId: sessionId)
    }
    
    func authorize(sessionId: String, rawToken: String, expires: TimeInterval) throws -> Token {
        return try queue.sync {
            let token = tokenMaker.token(token: rawToken, expires: expires, info: [:])
            try tokenStorage.save(token, for:  sessionId)
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
            cookiesHolder?.remove(for: sessionId)
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
        
        guard let url = request.url else {
            throw VKError.authorizationUrlIsNil
        }
        
        do {
            cookiesHolder?.replace(for: sessionId, url: url)
            let tokenInfo = try webPresenter.presentWith(urlRequest: request)
            token = try makeToken(tokenInfo: tokenInfo)
            cookiesHolder?.save(for: sessionId, url: url)
        }
        catch let error {
            guard let handledToken = handledToken else {
                cookiesHolder?.restore(for: url)
                throw error
            }
            
            token = handledToken
        }
        
        try tokenStorage.save(token, for:  sessionId)
        return token
    }
    
    private func makeToken(tokenInfo: String) throws -> Token {
        guard let parsingResult = tokenParser.parse(tokenInfo: tokenInfo) else {
            throw VKError.cantParseTokenInfo(tokenInfo)
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
            throw VKError.cantBuildWebViewUrl(webAuthorizeUrl + webQuery)
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
        }
        else {
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
