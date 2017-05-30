@testable import SwiftyVK

final class WebControllerMock: WebController {
    
    var onLoad: ((URL) -> ())?
    var onReload: (() -> ())?
    var onExpand: (() -> ())?
    var onGoBack: (() -> ())?
    var onDismiss: (() -> ())?

    
    func load(url: URL, handler: WebHandler) {        
        onLoad?(url)
    }
    
    func reload() {
        onReload?()
    }
    
    func expand() {
        onExpand?()
    }
    
    func goBack() {
        onGoBack?()
    }
    
    func dismiss() {
        onDismiss?()
    }
}
