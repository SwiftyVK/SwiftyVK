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
        case let (.upload(firstUrl, firstMedia, _), .upload(secondUrl, secondMedia, _)):
            return firstUrl == secondUrl && firstMedia == secondMedia
        default:
            return false
        }
    }
    
    public var hashValue: Int {
        switch self {
        case let .api(method, parameters):
            return method.hashValue ^ parameters.reduce(0) { $0 ^ $1.key.hashValue ^ $1.value.hashValue }
        case let .url(url):
            return url.hashValue
        case let .upload(url, media, _):
            return url.hashValue ^ media.reduce(0) { $0 ^ $1.data.hashValue }
        }
    }
}
