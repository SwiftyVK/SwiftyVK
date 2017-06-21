@testable import SwiftyVK

final class SwiftyVKDelegateMock: SwiftyVKDelegate {
    var vkNeedToPresent: ((VKViewController) -> ())?
    var onVkNeedsScopes: ((String) -> Scopes)?
    var onVkDidLogOut: ((String) -> ())?
    var onVkTokenCreated: ((String, [String : String]) -> ())?
    var onVkTokenUpdated: ((String, [String : String]) -> ())?
    var onVkTokenRemoved: ((String) -> ())?
    
    
    func vkNeedToPresent(viewController: VKViewController) {
        vkNeedToPresent?(viewController)
    }
    
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        return onVkNeedsScopes?(sessionId) ?? Scopes()
    }
    
    func vkDidLogOut(for sessionId: String) {
        onVkDidLogOut?(sessionId)
    }
    
    func vkTokenCreated(for sessionId: String, info: [String : String]) {
        onVkTokenCreated?(sessionId, info)
    }
    
    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
        onVkTokenUpdated?(sessionId, info)
    }
    
    func vkTokenRemoved(for sessionId: String) {
        onVkTokenRemoved?(sessionId)
    }
}
