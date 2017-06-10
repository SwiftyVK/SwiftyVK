protocol CaptchaController: class {
    func prepareForPresent()
    func present(imageData: Data, onFinish: @escaping (String) -> ())
    func dismiss()
}
