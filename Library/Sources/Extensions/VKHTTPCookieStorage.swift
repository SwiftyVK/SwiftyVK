protocol VKHTTPCookieStorage {
    func cookies(for: URL) -> [HTTPCookie]?
    func deleteCookie(_: HTTPCookie)
    func setCookies(_: [HTTPCookie], for: URL?, mainDocumentURL: URL?)
}

extension HTTPCookieStorage: VKHTTPCookieStorage {}
