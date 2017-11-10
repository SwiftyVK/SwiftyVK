@testable import SwiftyVK

final class ApiErrorExecutorMock: ApiErrorExecutor {
    
    var onLogIn: (() -> [String : String])?
    
    func logIn(revoke: Bool) throws -> [String : String] {
        return onLogIn?() ?? [:]
    }
    
    var onValidate: (() throws -> ())?
    
    func validate(redirectUrl: URL) throws {
        try onValidate?()
    }
    
    var onInvalidate: (() -> ())?
    
    func invalidate() {
        onInvalidate?()
    }
    
    var onCaptcha: (() throws -> String)?
    
    func captcha(rawUrlToImage: String, dismissOnFinish: Bool) throws -> String {
        return try onCaptcha?() ?? ""
    }
    
}
