@testable import SwiftyVK

final class VKAppProxyMock: VKAppProxy {
    
    var onCanSend: ((String) -> Bool)?
    var onSend: ((String) -> Bool)?
    var onHandle: ((URL, String?) -> String?)?
    
    func canSend(query: String) -> Bool {
        return onCanSend?(query) ?? false
    }
    
    @discardableResult
    func send(query: String) -> Bool {
        return onSend?(query) ?? false
    }
    
    func handle(url: URL, app: String?) -> String? {
        return onHandle?(url, app)
    }
}
