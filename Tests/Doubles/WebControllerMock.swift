@testable import SwiftyVK

final class WebControllerMock: WebController {
    
    var onLoad: ((URL?) -> ())?
    var onReload: (() -> ())?
    var onGoBack: (() -> ())?
    var onDismiss: (() -> ())?

    
    func load(urlRequest: URLRequest, handler: WebHandler) {
        onLoad?(urlRequest.url)
    }
    
    func reload() {
        onReload?()
    }
    
    func goBack() {
        onGoBack?()
    }
    
    func dismiss() {
        onDismiss?()
    }
}
