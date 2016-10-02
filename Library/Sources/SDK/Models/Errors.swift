import Foundation



enum VKAuthError : Int, Error {
    case presentingControllerIsNil  = 1
    case deniedFromUser             = 2
    case failingValidation          = 3
}



enum VKRequestError : Int, Error {
    case unexpectedResponseCode     = 1
    case timeoutExpired             = 2
    case maximumAttemptsExceeded    = 3
}



struct VKAPIError : Error {
    let code: Int
    let message: String
}
