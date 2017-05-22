@testable import SwiftyVK

final class TokenStorageMock: TokenStorage {
    
    var token: Token?
    
    var saveCallCount = 0
    
    func save(token: Token, for sessionId: String) {
        saveCallCount += 1
    }
    
    func getFor(sessionId: String) -> Token? {
        return token
    }
    
    var removeCallCount = 0
    
    func removeFor(sessionId: String) {
        removeCallCount += 1
    }
}
