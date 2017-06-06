@testable import SwiftyVK

final class SwiftyVKDelegateMock: SwiftyVKDelegate {
    
    var vkNeedToPresent: ((VkViewController) -> ())?
    var onVkNeedsScopes: ((String) -> Scopes)?
    var onVkDidLogOut: ((String) -> ())?
    var onVkTokenUpdated: ((String, [String : String]) -> ())?
    
    
    func vkNeedToPresent(viewController: VkViewController) {
        vkNeedToPresent?(viewController)
    }
    
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        return onVkNeedsScopes?(sessionId) ?? Scopes()
    }
    
    func vkDidLogOut(for sessionId: String) {
        onVkDidLogOut?(sessionId)
    }
    
    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
        onVkTokenUpdated?(sessionId, info)
    }
}
