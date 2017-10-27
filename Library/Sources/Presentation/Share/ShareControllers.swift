protocol ShareController: class {
    func share(_ context: ShareContext, completion: @escaping (ShareContext) -> ())
    func close()
    func showError(title: String, message: String, buttontext: String)
}
