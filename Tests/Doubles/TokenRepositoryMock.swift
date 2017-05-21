@testable import SwiftyVK

final class TokenRepositoryMock: TokenRepository {
    
    func save(token: Token, for sessionId: String) {
    }
    
    func getFor(sessionId: String) -> Token? {
        return nil
    }
    
    func removeFor(sessionId: String) {
        
    }
}
