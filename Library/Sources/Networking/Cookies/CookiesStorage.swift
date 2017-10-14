protocol CookiesStorage: class {
    func save(_: [HTTPCookie], for sessionId: String) throws
    func getFor(sessionId: String) -> [HTTPCookie]?
    func removeFor(sessionId: String)
}

final class CookiesStorageImpl: KeychainProvider<[HTTPCookie]>, CookiesStorage {}
