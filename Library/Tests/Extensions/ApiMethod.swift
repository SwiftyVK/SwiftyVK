@testable import SwiftyVK

extension RequestType {
    var apiMethod: String? {
        switch self {
        case let .api(method, _):
            return method
        default:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .api(_, parameters):
            return parameters
        default:
            return nil
        }
    }
}
