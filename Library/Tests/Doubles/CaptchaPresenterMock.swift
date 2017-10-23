@testable import SwiftyVK

final class CaptchaPresenterMock: CaptchaPresenter {
    
    var onPresent: (() throws -> String)?
    
    func present(rawCaptchaUrl: String, dismissOnFinish: Bool) throws -> String {
        return try onPresent?() ?? ""
    }
    
    var onDismiss: (() -> ())?
    
    func dismiss() {
        onDismiss?()
    }
}
