protocol ShareController: class {
    func share(
        _ context: ShareContext,
        onPost: @escaping (ShareContext) -> (),
        onDismiss: @escaping () -> ()
    )
    
    func wait()
    
    func showError(title: String, message: String, buttontext: String)

    func close()
}
