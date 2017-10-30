import UIKit

final class ShareImageCollectionCellIOS: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView?
    
    override func awakeFromNib() {
        imageView?.layer.cornerRadius = 10
        imageView?.layer.masksToBounds = true
        imageView?.layer.borderColor = UIColor.lightGray.cgColor
        imageView?.layer.borderWidth = 1 / UIScreen.main.nativeScale
    }
    
    func set(id: String, image: Data) {
        imageView?.image = UIImage(data: image)
    }
}
