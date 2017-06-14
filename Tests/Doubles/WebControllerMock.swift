@testable import SwiftyVK

final class WebControllerMock: WebController {
    
    var onLoad: ((URL?, (WebControllerResult) -> (), () -> ()) -> ())?
    var onReload: (() -> ())?
    var onGoBack: (() -> ())?
    var onDismiss: (() -> ())?

    
    func load(urlRequest: URLRequest, onResult: @escaping (WebControllerResult) -> (), onDismiss: @escaping () -> ()) {
        onLoad?(urlRequest.url, onResult, onDismiss)
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
