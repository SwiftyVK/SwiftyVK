@testable import SwiftyVK

final class WebPresenterMock: WebPresenter {
    
    var onPresesent: ((URLRequest) throws -> String)?
    
    func presentWith(urlRequest: URLRequest) throws -> String {
        return try onPresesent?(urlRequest) ?? ""
    }
    
    var onDismiss: (() -> ())?
    
    func dismiss() {
        onDismiss?()
    }
}
