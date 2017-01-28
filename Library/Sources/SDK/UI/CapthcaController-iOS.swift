#if os(iOS)
    import UIKit
    
    
    
    private let captchaViewName = Resources.withSuffix("CaptchaView")
    
    
    
    class CaptchaController: UIViewController, UITextFieldDelegate {
        
        @IBOutlet private weak var imageView: UIImageView!
        @IBOutlet private weak var textField: UITextField!
        private var parentView: UIViewController!
        private weak var delegate: CaptchaPresenter!
        private var image: UIImage?
        
        
        static func create(data: Data, delegate: CaptchaPresenter) -> CaptchaController? {
            
            guard let parent = VK.delegate?.vkWillPresentView(), let image = UIImage(data: data) else {
                return nil
            }
            
            let controller = CaptchaController(nibName: captchaViewName, bundle: Resources.bundle)
            controller.parentView = parent
            controller.image = image
            controller.delegate = delegate
            
            DispatchQueue.main.sync {
                controller.modalPresentationStyle = .overFullScreen
                controller.modalTransitionStyle = .crossDissolve
                controller.parentView?.present(controller, animated: true, completion: nil)
            }
            
            return controller
        }
        
        
        
        func setText(to text: String) {
            textField.text = text
        }
        
        
        
        override func viewWillAppear(_ animated: Bool) {
            imageView?.layer.cornerRadius = 15
            imageView?.layer.masksToBounds = true
            imageView.image = image
            textField.delegate = self
            textField.becomeFirstResponder()
            super.viewWillAppear(animated)
        }
        
        
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            delegate.didAppear()
        }
        
        
        
        override func viewDidDisappear(_ animated: Bool) {
            delegate?.finish(answer: nil)
            super.viewDidDisappear(animated)
            delegate = nil
        }
        
        
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.parentView?.dismiss(animated: true, completion: nil)
            delegate.finish(answer: self.textField.text)
            return true
        }
        
    }
#endif
