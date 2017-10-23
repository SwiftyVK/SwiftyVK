@testable import SwiftyVK

final class SwiftyVKDelegateMock: SwiftyVKDelegate {
    var vkNeedToPresent: ((VKViewController) -> ())?
    var onVKNeedsScopes: ((String) -> Scopes)?
    var onVKTokenCreated: ((String, [String : String]) -> ())?
    var onVKTokenUpdated: ((String, [String : String]) -> ())?
    var onVKTokenRemoved: ((String) -> ())?
    
    func vkNeedToPresent(viewController: VKViewController) {
        vkNeedToPresent?(viewController)
    }
    
    func vkNeedsScopes(for sessionId: String) -> Scopes {
        return onVKNeedsScopes?(sessionId) ?? Scopes()
    }
    
    func vkTokenCreated(for sessionId: String, info: [String : String]) {
        onVKTokenCreated?(sessionId, info)
    }
    
    func vkTokenUpdated(for sessionId: String, info: [String : String]) {
        onVKTokenUpdated?(sessionId, info)
    }
    
    func vkTokenRemoved(for sessionId: String) {
        onVKTokenRemoved?(sessionId)
    }
}
