@testable import SwiftyVK

final class ApiErrorHandlerMock: ApiErrorHandler {
    
    var onHandle: (() throws -> ApiErrorHandlerResult)?
    
    func handle(error: ApiError) throws -> ApiErrorHandlerResult {
        return try onHandle?() ?? .none
    }
}
