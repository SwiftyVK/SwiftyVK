@testable import SwiftyVK

final class TokenStorageMock: TokenStorage {
    
    var onSave: ((InvalidatableToken, String) -> ())?
    var onGet: ((String) -> InvalidatableToken?)?
    var onRemove: ((String) -> ())?
    
    func save(_ token: InvalidatableToken, for sessionId: String) {
        onSave?(token, sessionId)
    }
    
    func getFor(sessionId: String) -> InvalidatableToken? {
        return onGet?(sessionId)
    }
    
    func removeFor(sessionId: String) {
        onRemove?(sessionId)
    }
}
