import UIKit

class OnePixelConstraintIOS: NSLayoutConstraint {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constant = 1 / UIScreen.main.scale
    }
}
