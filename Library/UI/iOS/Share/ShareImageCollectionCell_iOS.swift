import UIKit

final class ShareImageCollectionCellIOS: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var overlayView: UIView?
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1 / UIScreen.main.nativeScale
    }
    
    func set(image: ShareImage) {
        imageView?.image = UIImage(data: image.data)
        
        image.setOnUpload { [weak self] in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self?.overlayView?.alpha = 0
                    self?.activityIndicator?.alpha = 0
                }
            }
        }
        
        if image.state == .uploaded {
            self.overlayView?.alpha = 0
            self.activityIndicator?.alpha = 0
        }
        else {
            overlayView?.alpha = 0.8
            activityIndicator?.alpha = 1
        }
    }
}
