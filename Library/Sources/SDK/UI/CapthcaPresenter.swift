import Foundation



internal final class CaptchaPresenter {
    private let semaphore = DispatchSemaphore(value: 0)
    private var controller: CaptchaController!
    private var sid: String
    private var answer: String?

    
    
    static func present(sid: String, imageUrl: String, request: RequestInstance) -> RequestError? {
        
        let presenter = CaptchaPresenter(sid: sid)

        return sheetQueue.sync {
            var data: Data

            do {
                let req = URLRequest(url: URL(string: imageUrl)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
                data = try NSURLConnection.sendSynchronousRequest(req, returning: nil)} catch _ {
                return RequestError.captchaFailed
            }
            
            guard let controller = CaptchaController.create(data: data, delegate: presenter) else {
                return RequestError.captchaFailed
            }
            
            presenter.controller = controller
            presenter.semaphore.wait()
            
            guard presenter.answer != nil else {
                return RequestError.captchaFailed
            }
            
            return nil
        }
    }
    
    
    
    private init(sid: String) {
        self.sid = sid
    }
    
    
    
    func didAppear() {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "TestCaptchaDidLoad"),
            object: nil,
            userInfo: ["captcha": controller]
        )
    }
    
    
    
    func finish(answer: String?) {
        self.answer = answer
        
        if let answer = answer {
            sharedCaptchaAnswer = [
                "captcha_sid": sid,
                "captcha_key": answer
            ]
        }
        
        semaphore.signal()
    }
    
}
