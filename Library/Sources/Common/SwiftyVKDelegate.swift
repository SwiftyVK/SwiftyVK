/// SwiftyVK delegate
public typealias SwiftyVKDelegate = SwiftyVKPresenterDelegate & SwiftyVKSessionDelegate & SwiftyVKAuthorizatorDelegate

public protocol SwiftyVKAuthorizatorDelegate: class {
    /// Called when SwiftyVK attempts get access to user account
    /// Should return set of permission scopes
    /// parameter sessionId: SwiftyVK session identifier
    func vkNeedsScopes(for sessionId: String) -> Scopes
}

public protocol SwiftyVKPresenterDelegate: class {
    /// Called when SwiftyVK wants to present UI (e.g webView or captcha)
    /// parameter viewController: view controller which should be presented from current top view controller
    func vkNeedToPresent(viewController: VKViewController)
}

public protocol SwiftyVKSessionDelegate: class {
    /// Called when user grant access and SwiftyVK gets new session token
    /// Can be used for run SwiftyVK requests and save session data
    /// parameter sessionId: SwiftyVK session identifier
    func vkTokenCreated(for sessionId: String, info: [String: String])
    
    /// Called when existing session token was expired and successfully refreshed
    /// Most likely here you do not do anything
    /// parameter sessionId: SwiftyVK session identifier
    /// parameter info: Authorized user info
    func vkTokenUpdated(for sessionId: String, info: [String: String])
    
    /// Called when user was logged out
    /// Use this point to cancel all SwiftyVK requests and remove session data
    /// parameter sessionId: SwiftyVK session identifier
    func vkTokenRemoved(for sessionId: String)
    
    /// Called when user grant access and SwiftyVK gets new code
    /// Can be used for authorize user on your server side
    /// parameter sessionId: SwiftyVK session identifier
    func vkCodeCreated(for sessionId: String, info: [String: String])
}

extension SwiftyVKSessionDelegate {
    
    // Default dummy methods implementations
    // Allows using its optionally
    
    public func vkTokenCreated(for sessionId: String, info: [String: String]) {}
    public func vkTokenUpdated(for sessionId: String, info: [String: String]) {}
    public func vkTokenRemoved(for sessionId: String) {}
    public func vkCodeCreated(for sessionId: String, info: [String: String]) {}
}
