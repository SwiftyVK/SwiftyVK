import Foundation

protocol CookiesHolder {
    func replace(for session: String, url: URL)
    func restore(for url: URL)
    func save(for session: String, url: URL)
    func remove(for sessionId: String)
}

final class CookiesHolderImpl: CookiesHolder {
    
    private let vkStorage: CookiesStorage
    private let sharedStorage: VKHTTPCookieStorage
    
    private var originalCookies: [HTTPCookie]?
    
    init(
        vkStorage: CookiesStorage,
        sharedStorage: VKHTTPCookieStorage
        ) {
        self.vkStorage = vkStorage
        self.sharedStorage = sharedStorage
    }
    
    func replace(for sessionId: String, url: URL) {
        originalCookies = sharedStorage.cookies(for: url)
        guard let cookies = vkStorage.getFor(sessionId: sessionId) else { return }
        sharedStorage.setCookies(cookies, for: url, mainDocumentURL: nil)
    }
    
    func restore(for url: URL) {
        guard let originalCookies = originalCookies else { return }
        sharedStorage.setCookies(originalCookies, for: url, mainDocumentURL: nil)
    }
    
    func save(for sessionId: String, url: URL) {
        guard let cookies = sharedStorage.cookies(for: url) else { return }
        try? vkStorage.save(cookies, for: sessionId)
    }
    
    func remove(for sessionId: String) {
        guard let cookies = vkStorage.getFor(sessionId: sessionId) else { return }
        cookies.forEach { sharedStorage.deleteCookie($0) }
        vkStorage.removeFor(sessionId: sessionId)
    }
}
