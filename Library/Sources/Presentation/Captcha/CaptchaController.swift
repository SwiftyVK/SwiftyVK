protocol CaptchaController: class, DismisableController {
    func prepareForPresent()
    func present(imageData: Data, onResult: @escaping (String) -> ())
    func dismiss()
}
