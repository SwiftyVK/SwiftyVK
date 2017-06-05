@testable import SwiftyVK

final class TokenStorageMock: TokenStorage {
    
    var onSave: ((Token, String) -> ())?
    var onGet: ((String) -> Token?)?
    var onRemove: ((String) -> ())?
    
    func save(token: Token, for sessionId: String) {
        onSave?(token, sessionId)
    }
    
    func getFor(sessionId: String) -> Token? {
        return onGet?(sessionId)
    }
    
    func removeFor(sessionId: String) {
        onRemove?(sessionId)
    }
}
