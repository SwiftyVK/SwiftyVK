import Foundation

public final class Request {
    
    let rawRequest: Raw
    var config: Config
    var nexts = [((Data) -> Request)]()
    
    init(
        of rawRequest: Raw,
        config: Config = .default
        ) {
        self.rawRequest = rawRequest
        self.config = config
    }
    
    @discardableResult
    public func next(_ next: @escaping ((Data) -> Request)) -> Request {
        nexts = [next] + nexts
        return self
    }
    
    @discardableResult
    public func send(with callbacks: Callbacks, in session: Session? = nil) -> Task {
        guard let session = session ?? VK.sessions?.default else {
            fatalError("You must call VK.prepareForUse function to start using SwiftyVK!")
        }
        
        config.inject(sessionConfig: session.config)
        return session.send(request: self, callbacks: callbacks)
    }
}

extension Request {
    enum Raw {
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
}

public struct Callbacks {
    
    public static let empty = Callbacks()
    
    let onSuccess: ((Data) -> ())?
    let onError: ((Error) -> ())?
    let onProgress: ((Int64, Int64) -> ())?
    
    public init(
        onSuccess: ((Data) -> ())? = nil,
        onError: ((Error) -> ())? = nil,
        onProgress: ((Int64, Int64) -> ())? = nil
        ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.onProgress = onProgress
    }
}

///HTTP prtocol methods. See - https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
public enum HttpMethod: String {
    case GET, POST
}
