public typealias SwiftyVKDelegate = SwiftyVKPresenterDelegate & SwiftyVKSessionDelegate & SwiftyVKAuthorizatorDelegate

public protocol SwiftyVKPresenterDelegate: class {
    func vkNeedToPresent(viewController: VKViewController)
}

public protocol SwiftyVKSessionDelegate: class {
    func vkTokenCreated(for sessionId: String, info: [String : String])
    func vkTokenUpdated(for sessionId: String, info: [String : String])
    func vkTokenRemoved(for sessionId: String)
}

public protocol SwiftyVKAuthorizatorDelegate: class {
    func vkNeedsScopes(for sessionId: String) -> Scopes
}
