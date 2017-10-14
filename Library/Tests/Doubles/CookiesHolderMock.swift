@testable import SwiftyVK
import XCTest

final class CookiesHolderMock: CookiesHolder {
    
    func replace(for session: String, url: URL) {}
    func restore(for url: URL) {}
    func save(for session: String, url: URL) {}
    func remove(for sessionId: String) {}
}
