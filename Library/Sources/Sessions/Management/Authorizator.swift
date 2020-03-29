import Foundation

protocol Authorizator: class {
    func getSavedToken(sessionId: String) -> InvalidatableToken?
    func authorize(sessionId: String, config: SessionConfig, revoke: Bool) throws -> InvalidatableToken
    func authorize(sessionId: String, rawToken: String, expires: TimeInterval) throws -> InvalidatableToken
    func authorizeCode(sessionId: String, config: SessionConfig, revoke: Bool) throws -> Code
    func validate(sessionId: String, url: URL) throws -> InvalidatableToken
    func reset(sessionId: String) -> InvalidatableToken?
    func handle(url: URL, app: String?)
}

final class AuthorizatorImpl: Authorizator {
    
    private let queue = DispatchQueue(label: "SwiftyVK.authorizatorQueue")
    private let webAuthorizeUrl = "https://oauth.vk.com/authorize?"
    private let webRedirectUrl = "https://oauth.vk.com/blank.html"
    
    private let appId: String
    private var tokenStorage: TokenStorage
    private weak var tokenMaker: TokenMaker?
    private weak var codeMaker: CodeMaker?
    private let tokenParser: TokenParser
    private let codeParser: CodeParser
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
        cookiesHolder: CookiesHolder?,
        codeParser: CodeParser,
        codeMaker: CodeMaker
        ) {
        self.appId = appId
        self.delegate = delegate
        self.tokenStorage = tokenStorage
        self.tokenMaker = tokenMaker
        self.tokenParser = tokenParser
        self.vkAppProxy = vkAppProxy
        self.webPresenter = webPresenter
        self.cookiesHolder = cookiesHolder
        self.codeParser = codeParser
        self.codeMaker = codeMaker
    }
    
    func authorizeCode(sessionId: String, config: SessionConfig, revoke: Bool) throws -> Code {
        return try queue.sync {
            guard let scopes = delegate?.vkNeedsScopes(for: sessionId).rawValue else {
                throw VKError.vkDelegateNotFound
            }
            
            let webAuthRequest = try makeWebAuthRequest(
                sessionId: sessionId,
                config: config,
                scopes: scopes,
                revoke: revoke,
                responseType: "code"
            )
            
            return try getCode(request: webAuthRequest)
        }
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
                revoke: revoke,
                responseType: "token" // VK iOS & Android Apps do not support any response type except 'token'
            )
            
            let webAuthRequest = try makeWebAuthRequest(
                sessionId: sessionId,
                config: config,
                scopes: scopes,
                revoke: revoke,
                responseType: "token"
            )
            
            try vkAppProxy.send(query: vkAppAuthQuery)
            return try getToken(sessionId: sessionId, request: webAuthRequest)
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
    
    private func getCode(request: URLRequest) throws -> Code {
        defer { webPresenter.dismiss() }
        return try webCode(request: request)
    }
    
    private func webCode(request: URLRequest) throws -> Code {
        defer { webPresenter.dismiss() }
        
        guard request.url != nil else {
            throw VKError.authorizationUrlIsNil
        }
        
        do {
            let codeInfo = try webPresenter.presentWith(urlRequest: request)
            let code = try makeCode(codeInfo: codeInfo)
            return code
        }
        catch {
            throw error
        }
        
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
    
    private func makeCode(codeInfo: String) throws -> Code {
        guard let parsingResult = codeParser.parse(codeInfo: codeInfo) else {
            throw VKError.cantParseTokenInfo(codeInfo)
        }
        
        guard let codeMaker = codeMaker else {
            throw VKError.weakObjectWasDeallocated
        }
        
        return codeMaker.code(
            code: parsingResult.code,
            info: parsingResult.info
        )
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
        revoke: Bool,
        responseType: String
        ) throws -> URLRequest {
        let webQuery = try makeAuthQuery(
            sessionId: sessionId,
            config: config,
            scopes: scopes,
            redirectUrl: webRedirectUrl,
            revoke: revoke,
            responseType: responseType
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
        revoke: Bool,
        responseType: String
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
            + "response_type=\(responseType)&"
            + "revoke=\(revoke ? 1 : 0)"
    }
}
