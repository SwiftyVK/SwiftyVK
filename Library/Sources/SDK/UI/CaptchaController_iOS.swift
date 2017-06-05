import UIKit

final class CaptchaController_iOS: UIViewController, UITextFieldDelegate, CaptchaController {
    
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var textField: UITextField?
    private var onFinish: ((String) -> ())?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView?.layer.cornerRadius = 15
        imageView?.layer.masksToBounds = true
        textField?.delegate = self
        textField?.becomeFirstResponder()
    }
    
    func present(imageData: Data, onFinish: @escaping (String) -> ()) {
        self.imageView?.image = UIImage(data: imageData)
        self.onFinish = onFinish
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let result = textField.text, !result.isEmpty else {
            return false
        }
        
        onFinish?(result)
        return true
    }
}
