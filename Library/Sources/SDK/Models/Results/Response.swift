import Foundation

public enum Response<Result, ParserError: Error> {
    case success(Result)
    case error(VkError<ParserError>)
}
