import UIKit

final class CaptchaController_iOS: UIViewController, UITextFieldDelegate, CaptchaController {
    
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var textField: UITextField?
    @IBOutlet weak var preloader: UIActivityIndicatorView?
    @IBOutlet weak var closeButton: UIButton?
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint?
    private var onResult: ((String) -> ())?
    private var onDismiss: (() -> ())?
    private var appeared = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView?.layer.backgroundColor = UIColor.white.withAlphaComponent(0.75).cgColor
        imageView?.layer.cornerRadius = 15
        imageView?.layer.masksToBounds = true
        imageView?.layer.borderColor = UIColor.lightGray.cgColor
        imageView?.layer.borderWidth = 1 / UIScreen.main.nativeScale
        
        textField?.delegate = self
        textField?.becomeFirstResponder()
        
        preloader?.color = .lightGray
        
        closeButton?.setImage(
            UIImage(named: "CloseButton", in: Resources.bundle, compatibleWith: nil),
            for: .normal
        )
        
        closeButton?.setImage(
            UIImage(named: "CloseButtonPressed", in: Resources.bundle, compatibleWith: nil),
            for: .highlighted
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: .UIKeyboardWillChangeFrame,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appeared = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField?.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
        appeared = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
    
    func prepareForPresent() {
        DispatchQueue.main.async {
            self.imageView?.image = nil
            self.textField?.text = nil
            self.textField?.alpha = 0.75
            self.preloader?.startAnimating()
        }
    }
    
    func present(imageData: Data, onResult: @escaping (String) -> (), onDismiss: @escaping () -> ()) {
        DispatchQueue.main.sync {
            imageView?.image = UIImage(data: imageData)
            textField?.alpha = 1
            preloader?.stopAnimating()
        }
        
        self.onResult = onResult
        self.onDismiss = onDismiss
    }
    
    @IBAction func dismissByButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard
            imageView?.image != nil,
            let result = textField.text,
            !result.isEmpty
            else {
                return false
        }
        
        onResult?(result)
        return true
    }
    
    @objc private func keyboardWillChange(notification: Notification) {
        guard
            let info = (notification as NSNotification).userInfo,
            let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardFrameEnd = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let viewAnimationCurveValue = (info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let viewAnimationCurve = UIViewAnimationCurve(rawValue: viewAnimationCurveValue)
            else {
                return
        }
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(viewAnimationCurve)
        UIView.setAnimationBeginsFromCurrentState(false)
        
        containerBottomConstraint?.constant = keyboardFrameEnd.height
        appeared ? view.layoutIfNeeded() : ()
        
        UIView.commitAnimations()
    }
}
