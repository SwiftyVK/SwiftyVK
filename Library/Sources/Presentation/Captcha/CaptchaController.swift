protocol CaptchaController: class {
    func prepareForPresent()
    func present(imageData: Data, onResult: @escaping (String) -> (), onDismiss: @escaping () -> ())
    func dismiss()
}
