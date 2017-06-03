protocol WebController: class {
    func load(urlRequest: URLRequest, handler: WebHandler)
    func reload()
    func goBack()
    func dismiss()
}
