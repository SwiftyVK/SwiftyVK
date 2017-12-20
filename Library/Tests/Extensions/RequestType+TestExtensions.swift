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
    
    public var hashValue: Int {
        switch self {
        case let .api(method, parameters):
            return method.hashValue ^ Set(parameters.map { $0.key + $0.value }).hashValue
        case let .url(url):
            return url.hashValue
        case let .upload(url, media, partType):
            return url.hashValue ^ partType.hashValue ^ Set(media).hashValue
        }
    }
}

extension Media: Hashable {
    
    public var hashValue: Int {
       return type.hashValue ^ data.hashValue
    }
}
