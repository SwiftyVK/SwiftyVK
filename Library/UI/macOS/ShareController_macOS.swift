import Cocoa

final class ShareControllerMacOS: NSViewController, ShareController {
    
    var onDismiss: (() -> ())?
    
    func showWaitForConnection() {
        
    }
    
    func share(_ context: ShareContext, onPost: @escaping (ShareContext) -> ()) {
        
    }
    
    func showPlaceholder() {
        
    }
    
    func enablePostButton(_ enable: Bool) {
        
    }
    
    func showError(title: String, message: String, buttontext: String) {
        
    }
    
    func close() {
        
    }
}
