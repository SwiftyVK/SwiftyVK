protocol WebController: class {
    func load(url: URL, handler: WebHandler)
    func reload()
    func expand()
    func goBack()
    func dismiss()
}
