@testable import SwiftyVK

extension ApiError {
    init(code: Int, otherInfo: [String: String] = [:]) {
        self.code = code
        self.message = ""
        self.requestParams = [:]
        self.otherInfo = otherInfo
    }
}
