@testable import SwiftyVK

final class ApiErrorHandlerMock: ApiErrorHandler {
    
    var onHandle: (() throws -> ApiErrorHandlerResult)?
    
    func handle(error: ApiError, token: Token? = nil) throws -> ApiErrorHandlerResult {
        return try onHandle?() ?? .none
    }
}
