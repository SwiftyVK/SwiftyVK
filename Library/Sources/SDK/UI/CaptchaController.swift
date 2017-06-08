protocol CaptchaController: class {
    func present(imageData: Data, onFinish: @escaping (String) -> ())
    func dismiss()
}
