protocol WebController: class {
    func load(urlRequest: URLRequest, onResult: @escaping (WebControllerResult) -> (), onDismiss: @escaping () -> ())
    func reload()
    func goBack()
    func dismiss()
}
