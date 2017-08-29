@testable import SwiftyVK

final class VKAppProxyMock: VKAppProxy {
    
    var onSend: ((String) throws -> Bool)?
    var onHandle: ((URL, String?) -> String?)?
    
    func send(query: String) throws -> Bool {
        return try onSend?(query) ?? false
    }
    
    func handle(url: URL, app: String?) -> String? {
        return onHandle?(url, app)
    }
}
