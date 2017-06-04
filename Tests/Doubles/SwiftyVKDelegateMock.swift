@testable import SwiftyVK

final class SwiftyVKDelegateMock: SwiftyVKDelegate {
    
    var vkNeedToPresent: ((VkViewController) -> ())?
    var onVkWillLogIn: ((Session) -> Scopes)?
    var onVkDidLogOut: ((Session) -> ())?
    
    
    func vkNeedToPresent(viewController: VkViewController) {
        vkNeedToPresent?(viewController)
    }
    
    func vkWillLogIn(in session: Session) -> Scopes {
        return onVkWillLogIn?(session) ?? Scopes()
    }
    
    func vkDidLogOut(in session: Session) {
        onVkDidLogOut?(session)
    }
}
