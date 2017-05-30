protocol WebController: class {
    func load(url: URL, handler: WebHandler) throws
    func reload()
    func expand()
    func goBack()
    func dismiss()
}
