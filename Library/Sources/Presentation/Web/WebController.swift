import Foundation

protocol WebController: DismisableController {
    func load(urlRequest: URLRequest, onResult: @escaping (WebControllerResult) -> ())
    func reload()
    func goBack()
    func dismiss()
}
