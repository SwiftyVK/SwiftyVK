import Foundation



struct APIError : Error {
    let code: Int
    let message: String
}



enum VKError_ : Int, Error {
    case userNotAuthorized = 1
    case userFailValidation = 2
    case unexpectedResponseCode = 3
    case timeoutExpired = 4
    case maximumAttemptsExceeded = 5
}
