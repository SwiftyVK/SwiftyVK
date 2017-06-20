public typealias SwiftyVKDelegate = SwiftyVKPresenterDelegate & SwiftyVKSessionDelegate & SwiftyVKAuthorizatorDelegate

public protocol SwiftyVKPresenterDelegate: class {
    func vkNeedToPresent(viewController: VkViewController)
}

public protocol SwiftyVKSessionDelegate: class {
    func vkDidLogOut(for sessionId: String)
    func vkTokenUpdated(for sessionId: String, info: [String : String])
}

public protocol SwiftyVKAuthorizatorDelegate: class {
    func vkNeedsScopes(for sessionId: String) -> Scopes
}
