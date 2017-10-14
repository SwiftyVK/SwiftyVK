@testable import SwiftyVK

extension Response {
    
    static var emptySuccess: Response {
        return .success(Data())
    }
    
    static var unexpectedError: Response {
        return .error(.unexpectedResponse)
    }
    
    var data: Data? {
        switch self {
        case let .success(data):
            return data
        case .error:
            return nil
        }
    }
    
    var error: VKError? {
        switch self {
        case .success:
            return nil
        case let .error(error):
            return error
        }
    }
}
