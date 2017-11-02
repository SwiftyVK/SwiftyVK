protocol ShareController: class {
    func share(
        _ context: ShareContext,
        onPost: @escaping (ShareContext) -> (),
        onDismiss: @escaping () -> ()
    )
    
    func enablePostButton(_ enable: Bool)
    
    func showError(title: String, message: String, buttontext: String)

    func close()
}


protocol SharePreferencesController: class {
    func set(preferences: [ShareContextPreference])
}
