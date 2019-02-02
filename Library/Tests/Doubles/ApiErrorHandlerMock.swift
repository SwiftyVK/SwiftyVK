@testable import SwiftyVK

final class ApiErrorHandlerMock: ApiErrorHandler {
    
    var onHandle: (() throws -> ApiErrorHandlerResult)?
    
    func handle(error: ApiError, token: InvalidatableToken? = nil) throws -> ApiErrorHandlerResult {
        return try onHandle?() ?? .none
    }
}
