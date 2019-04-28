@testable import SwiftyVK

extension RequestType: Equatable, Hashable {
    var apiMethod: String? {
        switch self {
        case let .api(method, _):
            return method
        default:
            return nil
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case let .api(_, parameters):
            return parameters
        default:
            return nil
        }
    }
    
    public static func ==(lhs: RequestType, rhs: RequestType) -> Bool {
        switch (lhs, rhs) {
        case let (.api(firstMethod, firstParameters), .api(secondMethod, secondParameters)):
            return firstMethod == secondMethod && firstParameters == secondParameters
        case let (.url(firstUrl), .url(secondUrl)):
            return firstUrl == secondUrl
        case let (.upload(firstUrl, firstMedia, firstPartType), .upload(secondUrl, secondMedia, secondPartType)):
            return firstUrl == secondUrl && firstMedia == secondMedia && firstPartType == secondPartType
        default:
            return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        let hash: Int
        
        switch self {
        case let .api(method, parameters):
            hash = method.hashValue ^ Set(parameters.map { $0.key + $0.value }).hashValue
        case let .url(url):
            hash = url.hashValue
        case let .upload(url, media, partType):
            hash = url.hashValue ^ partType.hashValue ^ Set(media).hashValue
        }
        
        hasher.combine(hash)
    }
}

extension Media: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type.hashValue ^ data.hashValue)
    }
}
