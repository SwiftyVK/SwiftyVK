import UIKit

final class CaptchaController_iOS: UIViewController, UITextFieldDelegate, CaptchaController {
    
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var textField: UITextField?
    private var onFinish: ((String) -> ())?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .coverVertical
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView?.layer.cornerRadius = 15
        imageView?.layer.masksToBounds = true
        textField?.delegate = self
        textField?.becomeFirstResponder()
    }
    
    func present(imageData: Data, onFinish: @escaping (String) -> ()) {
        DispatchQueue.main.sync {
            imageView?.image = UIImage(data: imageData)
            textField?.text = nil
        }
        self.onFinish = onFinish
    }
    
    func dismiss() {
        DispatchQueue.main.sync {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let result = textField.text, !result.isEmpty else {
            return false
        }
        
        onFinish?(result)
        return true
    }
}
