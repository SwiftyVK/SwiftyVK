protocol ShareController: DismisableController {
    func share(
        _ context: ShareContext,
        onPost: @escaping (ShareContext) -> ()
    )
    
    func showPlaceholder()
    func showWaitForConnection()
    func enablePostButton(_ enable: Bool)
    
    func showError(title: String, message: String, buttontext: String)

    func close()
}

protocol SharePreferencesController: AnyObject {
    func set(preferences: [ShareContextPreference])
}
