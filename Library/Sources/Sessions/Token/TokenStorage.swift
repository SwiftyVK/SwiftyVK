protocol TokenStorage: AnyObject {
    func save(_: InvalidatableToken, for sessionId: String) throws
    func getFor(sessionId: String) -> InvalidatableToken?
    func removeFor(sessionId: String)
}

final class TokenStorageImpl: KeychainProvider<InvalidatableToken>, TokenStorage {}
