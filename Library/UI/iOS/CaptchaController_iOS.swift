#if os(iOS)
import UIKit

final class CaptchaControllerIOS: UIViewController, UITextFieldDelegate, CaptchaController {
    
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var textField: UITextField?
    @IBOutlet private weak var preloader: UIActivityIndicatorView?
    @IBOutlet private weak var closeButton: UIButton?
    @IBOutlet private weak var containerBottomConstraint: NSLayoutConstraint?
    private var onResult: ((String) -> ())?
    var onDismiss: (() -> ())?
    private var appeared = false
    
    var isDisplayed: Bool {
        return DispatchQueue.anywayOnMain {
            isViewLoaded && view.window != nil
        }
    }
    
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
            name: UIResponder.keyboardWillChangeFrameNotification,
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
    
    func present(imageData: Data, onResult: @escaping (String) -> ()) {
        DispatchQueue.main.sync {
            imageView?.image = UIImage(data: imageData)
            textField?.alpha = 1
            preloader?.stopAnimating()
        }
        
        self.onResult = onResult
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
    
    @objc
    private func keyboardWillChange(notification: Notification) {
        guard
            let info = (notification as NSNotification).userInfo,
            let animationDuration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardFrameEnd = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let viewAnimationCurveValue = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let viewAnimationCurve = UIView.AnimationCurve(rawValue: viewAnimationCurveValue)
            else {
                return
        }
        
        let options = UIView.AnimationOptions(rawValue: UInt(viewAnimationCurve.rawValue << 16))
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: [options],
            animations: {
                self.containerBottomConstraint?.constant = keyboardFrameEnd.height
                if self.appeared {
                    self.view.layoutIfNeeded()
                }
            },
            completion: nil
        )
    }
}

#endif
