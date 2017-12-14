import Cocoa

final class ShareImageCollectionViewItemMacOS: NSCollectionViewItem {
    
    @IBOutlet private weak var overlayView: NSView?
    @IBOutlet private weak var activityIndicator: NSProgressIndicator?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        view.layer?.masksToBounds = true
        view.layer?.borderColor = NSColor.lightGray.cgColor
        view.layer?.borderWidth = 1 / (NSScreen.main?.backingScaleFactor ?? 1)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        overlayView?.alphaValue = 0.8
        activityIndicator?.alphaValue = 1
    }
    
    func set(image: ShareImage) {
        let nsImage = NSImage(data: image.data)?.squared
        imageView?.image = nsImage
        activityIndicator?.startAnimation(self)
        
        image.setOnUpload { [weak self] in
            DispatchQueue.main.async {
                guard nsImage == self?.imageView?.image else { return }
                
                NSAnimationContext.runAnimationGroup({ _ in
                        self?.overlayView?.animator().alphaValue = 0
                        self?.activityIndicator?.animator().alphaValue = 0
                    },
                    completionHandler: nil
                )
            }
        }
        
        if image.state == .uploaded {
            self.overlayView?.alphaValue = 0
            self.activityIndicator?.alphaValue = 0
        }
        else {
            overlayView?.alphaValue = 0.8
            activityIndicator?.alphaValue = 1
        }
    }
}
