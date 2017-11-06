protocol ShareController: class, DismisableController {
    func share(
        _ context: ShareContext,
        onPost: @escaping (ShareContext) -> ()
    )
    
    func showPlaceholder(_ enable: Bool)
    func showWaitForConnection()
    func enablePostButton(_ enable: Bool)
    
    func showError(title: String, message: String, buttontext: String)

    func close()
}

protocol SharePreferencesController: class {
    func set(preferences: [ShareContextPreference])
}
