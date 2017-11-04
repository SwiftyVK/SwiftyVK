@testable import SwiftyVK
import XCTest

final class ShareControllerMock: ShareController {

    var onShare: ((ShareContext, @escaping (ShareContext) -> (), @escaping () -> ()) -> ())?
    
    func share(_ context: ShareContext, onPost: @escaping (ShareContext) -> (), onDismiss: @escaping () -> ()) {
      onShare?(context, onPost, onDismiss)
    }
    
    func showPlaceholder(_ enable: Bool) {
        
    }
    
    func enablePostButton(_ enable: Bool) {
        
    }
    
    var onClose: (() -> ())?
    
    func close() {
        onClose?()
    }
    
    var onShowError: ((String, String, String) -> ())?
    
    func showError(title: String, message: String, buttontext: String) {
        onShowError?(title, message, buttontext)
    }
}
