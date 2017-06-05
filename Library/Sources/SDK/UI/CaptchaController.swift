protocol CaptchaController {
    func present(imageData: Data, onFinish: @escaping (String) -> ())
    func dismiss()
}
