import Foundation

public final class Request {
    let type: RequestType
    var config: Config
    var callbacks: Callbacks
    var nexts: [((Data) -> Request)]
    
    init(
        type: RequestType,
        config: Config = .default,
        callbacks: Callbacks = .empty,
        nexts: [((Data) -> Request)] = []
        ) {
        self.type = type
        self.config = config
        self.callbacks = callbacks
        self.nexts = nexts
    }
    
    @discardableResult
    func next(_ next: @escaping ((Data) -> Request)) -> Request {
        nexts.insert(next, at: 0)
        return self
    }
    
    func toMethod() -> Methods.Basic {
        return Methods.Basic(self)
    }
}

enum RequestType {
    case api(method: String, parameters: Parameters)
    case url(String)
    case upload(url: String, media: [Media], partType: PartType)
    
    var canSentConcurrently: Bool {
        switch self {
        case .api:
            return false
        case .url, .upload:
            return true
        }
    }
}

public enum ProgressType {
    case sended
    case recieved
}

///HTTP prtocol methods. See - https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
public enum HttpMethod: String {
    case GET, POST
}
