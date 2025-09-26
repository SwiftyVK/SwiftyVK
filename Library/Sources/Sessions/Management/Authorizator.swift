import Foundation

protocol Authorizator: class {
    func getSavedToken(sessionId: String) -> InvalidatableToken?
    func authorize(sessionId: String, config: SessionConfig, revoke: Bool) throws -> InvalidatableToken
    func authorize(sessionId: String, rawToken: String, expires: TimeInterval) throws -> InvalidatableToken
    func validate(sessionId: String, url: URL) throws -> InvalidatableToken
    func reset(sessionId: String) -> InvalidatableToken?
    func handle(url: URL, app: String?)
}

final class AuthorizatorImpl: Authorizator {
    
    private let queue = DispatchQueue(label: "SwiftyVK.authorizatorQueue")
    private let webAuthorizeUrl = VKDomains.oauthAuthorizeUrl
    private let webRedirectUrl = VKDomains.oauthRedirectUrl
    
    private let appId: String
    private var tokenStorage: TokenStorage
    private weak var tokenMaker: TokenMaker?
    private let tokenParser: TokenParser
    private let vkAppProxy: VKAppProxy
    private let webPresenter: WebPresenter
    private let cookiesHolder: CookiesHolder?
    private weak var delegate: SwiftyVKAuthorizatorDelegate?
    
    private(set) var vkAppToken: InvalidatableToken?
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
    
    func authorize(sessionId: String, config: SessionConfig, revoke: Bool) throws -> InvalidatableToken {
        defer { vkAppToken = nil }
        
        return try queue.sync {
            
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
            
            let webAuthRequest = try makeWebAuthRequest(
                sessionId: sessionId,
                config: config,
                scopes: scopes,
                revoke: revoke
            )

            return try getToken(sessionId: sessionId, webRequest: webAuthRequest, appAuthQuery: vkAppAuthQuery)
        }
    }
    
    func getSavedToken(sessionId: String) -> InvalidatableToken? {
        return queue.sync {
            tokenStorage.getFor(sessionId: sessionId)
        }
    }
    
    func authorize(sessionId: String, rawToken: String, expires: TimeInterval) throws -> InvalidatableToken {
        return try queue.sync {
            guard let tokenMaker = tokenMaker else {
                throw VKError.weakObjectWasDeallocated
            }
            
            let token = tokenMaker.token(token: rawToken, expires: expires, info: [:])
            try tokenStorage.save(token, for:  sessionId)
            return token
        }
    }
    
    func validate(sessionId: String, url: URL) throws -> InvalidatableToken {
        return try queue.sync {
            let validationRequest = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: requestTimeout
            )
            
            return try getToken(sessionId: sessionId, request: validationRequest)
        }
    }
    
    func reset(sessionId: String) -> InvalidatableToken? {
        return queue.sync {
            tokenStorage.removeFor(sessionId: sessionId)
            cookiesHolder?.remove(for: sessionId)
            return nil
        }
    }
    
    func handle(url: URL, app: String?) {
        guard
            let tokenInfo = vkAppProxy.handle(url: url, app: app),
            let vkAppToken = try? makeToken(tokenInfo: tokenInfo) else
        {
            return
        }
        
        self.vkAppToken = vkAppToken
        webPresenter.dismiss()
    }
    
    private func getToken(sessionId: String, request: URLRequest) throws -> InvalidatableToken {
        defer { webPresenter.dismiss() }

        let token = try vkAppToken ?? webToken(sessionId: sessionId, request: request)
        try tokenStorage.save(token, for:  sessionId)
        return token
    }

    private func getToken(
        sessionId: String,
        webRequest: URLRequest,
        appAuthQuery: String
        ) throws -> InvalidatableToken {
        defer { webPresenter.dismiss() }

        let token: InvalidatableToken
        if vkAppProxy.canSend(query: appAuthQuery) {
            guard vkAppProxy.send(query: appAuthQuery) else {
                throw VKError.vkAppFailedToOpen
            }

            guard let vkAppToken = vkAppToken else {
                throw VKError.vkAppTokenNotReceived
            }

            token = vkAppToken
        }
        else {
            token = try webToken(sessionId: sessionId, request: webRequest)
        }

        try tokenStorage.save(token, for:  sessionId)
        return token
    }
    
    private func webToken(sessionId: String, request: URLRequest) throws -> InvalidatableToken {
        defer { webPresenter.dismiss() }

        guard let url = request.url else {
            throw VKError.authorizationUrlIsNil
        }
        
        do {
            cookiesHolder?.replace(for: sessionId, url: url)
            let tokenInfo = try webPresenter.presentWith(urlRequest: request)
            let token = try makeToken(tokenInfo: tokenInfo)
            cookiesHolder?.save(for: sessionId, url: url)
            return token
        }
        catch {
            guard let vkAppToken = vkAppToken else {
                cookiesHolder?.restore(for: url)
                throw error
            }
            
            return vkAppToken
        }
        
    }
    
    private func makeToken(tokenInfo: String) throws -> InvalidatableToken {
        guard let parsingResult = tokenParser.parse(tokenInfo: tokenInfo) else {
            throw VKError.cantParseTokenInfo(tokenInfo)
        }
        
        guard let tokenMaker = tokenMaker else {
            throw VKError.weakObjectWasDeallocated
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
