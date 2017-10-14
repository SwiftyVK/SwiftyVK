@testable import SwiftyVK

final class WebControllerMock: WebController {
    
    var onLoad: ((URL?, @escaping (WebControllerResult) -> (), () -> ()) -> ())?
    var onGoBack: (() -> ())?
    var onReload: (() -> ())?
    var onDismiss: (() -> ())?
    
    private var realOnDismiss: (() -> ())?
    
    func load(urlRequest: URLRequest, onResult: @escaping (WebControllerResult) -> (), onDismiss: @escaping () -> ()) {
        realOnDismiss = onDismiss
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
        realOnDismiss?()
    }
}
