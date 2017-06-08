protocol ApiErrorHandler {
    func handle(error: ApiError, onCaptchaEnter: (Captcha) -> ()) throws
}

final class ApiErrorHandlerImpl: ApiErrorHandler {
    
    private let session: ApiErrorExecutor
    
    init(session: ApiErrorExecutor) {
        self.session = session
    }
    
    func handle(error: ApiError, onCaptchaEnter: (Captcha) -> ()) throws {
        switch error.errorCode {
        case 5:
            _ = try session.logIn(revoke: false)
        case 14:
            guard
                let sid = error.errorUserInfo["captcha_sid"] as? String,
                let imgRawUrl = error.errorUserInfo["captcha_img"] as? String
                else {
                    throw error
            }
            
            let key = try session.captcha(rawUrlToImage: imgRawUrl, dismissOnFinish: false)
            onCaptchaEnter(Captcha(sid, key))
        case 17:
            guard
                let rawUrl = error.errorUserInfo["redirect_uri"] as? String,
                let url = URL(string: rawUrl)
                else {
                    throw error
            }
            
            try session.validate(redirectUrl: url)
        default:
            throw error
        }
    }
}
