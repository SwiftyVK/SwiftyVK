import Foundation

public protocol SwiftyVkParser {
    associatedtype CustomResult
    associatedtype CustomError: Error
    
    func parse(_ data: Data) -> Response<CustomResult, CustomError>
}
