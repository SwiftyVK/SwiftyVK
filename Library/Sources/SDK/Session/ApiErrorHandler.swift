protocol ApiErrorHandler {
    func handle(error: ApiError) throws -> ApiErrorHandlerResult
}

final class ApiErrorHandlerImpl: ApiErrorHandler {
    
    private let session: ApiErrorExecutor
    
    init(session: ApiErrorExecutor) {
        self.session = session
    }
    
    func handle(error: ApiError) throws -> ApiErrorHandlerResult {
        switch error.errorCode {
        case 5:
            _ = try session.logIn(revoke: false)
            return .none
        case 14:
            guard
                let sid = error.errorUserInfo["captcha_sid"] as? String,
                let imgRawUrl = error.errorUserInfo["captcha_img"] as? String
                else {
                    throw error
            }
            
            let key = try session.captcha(rawUrlToImage: imgRawUrl, dismissOnFinish: false)
            return .captcha(Captcha(sid, key))
        case 17:
            guard
                let rawUrl = error.errorUserInfo["redirect_uri"] as? String,
                let url = URL(string: rawUrl)
                else {
                    throw error
            }
            
            try session.validate(redirectUrl: url)
            return .none
        default:
            throw error
        }
    }
}

enum ApiErrorHandlerResult {
    case captcha(Captcha)
    case none
}
