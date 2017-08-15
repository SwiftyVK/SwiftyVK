protocol ApiErrorHandler {
    func handle(error: ApiError) throws -> ApiErrorHandlerResult
}

final class ApiErrorHandlerImpl: ApiErrorHandler {
    
    private let session: ApiErrorExecutor
    
    init(session: ApiErrorExecutor) {
        self.session = session
    }
    
    func handle(error: ApiError) throws -> ApiErrorHandlerResult {
        switch error.code {
        case 5:
            _ = try session.logIn(revoke: false)
            return .none
        case 14:
            guard
                let sid = error.otherInfo["captcha_sid"],
                let imgRawUrl = error.otherInfo["captcha_img"]
                else {
                    throw VkError.api(error)
            }
            
            let key = try session.captcha(rawUrlToImage: imgRawUrl, dismissOnFinish: false)
            return .captcha(Captcha(sid, key))
        case 17:
            guard
                let rawUrl = error.otherInfo["redirect_uri"],
                let url = URL(string: rawUrl)
                else {
                    throw VkError.api(error)
            }
            
            try session.validate(redirectUrl: url)
            return .none
        default:
            throw VkError.api(error)
        }
    }
}

enum ApiErrorHandlerResult {
    case captcha(Captcha)
    case none
}
