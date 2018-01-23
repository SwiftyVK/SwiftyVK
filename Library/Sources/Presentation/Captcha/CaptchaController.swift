import Foundation

protocol CaptchaController: DismisableController {
    var isDisplayed: Bool { get }
    
    func prepareForPresent()
    func present(imageData: Data, onResult: @escaping (String) -> ())
    func dismiss()
}
