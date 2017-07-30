import Foundation

public enum RequestError: Error {
    case unexpectedResponse
    case jsonNotParsed(Error)
}
