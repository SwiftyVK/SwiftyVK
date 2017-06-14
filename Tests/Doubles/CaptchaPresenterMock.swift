@testable import SwiftyVK

final class CaptchaPresenterMock: CaptchaPresenter {
    
    var onPresent: (() throws -> String)?
    
    var onDismiss: (() -> ())?
    
    func present(rawCaptchaUrl: String, dismissOnFinish: Bool) throws -> String {
        return try onPresent?() ?? ""
    }
    
    func dismiss() {
        onDismiss?()
    }
}
