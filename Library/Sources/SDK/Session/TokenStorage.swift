import Foundation

protocol TokenStorage: class {
    func save(_: Token, for sessionId: String) throws
    func getFor(sessionId: String) -> Token?
    func removeFor(sessionId: String)
}

final class TokenStorageImpl: KeychainProvider<Token>, TokenStorage {}
