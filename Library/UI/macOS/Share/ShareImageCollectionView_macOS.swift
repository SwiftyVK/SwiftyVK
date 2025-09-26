#if os(macOS)
import Cocoa

@available(iOS 8.0, macOS 10.11, *)
final class ShareImageCollectionViewMacOS: NSCollectionView, NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    private var images = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = NSNib(
            nibNamed: "ShareImageCollectionViewItem_macOS",
            bundle: Resources.bundle
        )
        register(
            nib,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ShareImageCollectionViewItem")
        )
        
        dataSource = self
        delegate = self
    }
    
    func set(images: [ShareImage]) {
        self.images = NSMutableArray(array: images)
        
        images.forEach { [weak self] image in
            image.setOnFail {
                DispatchQueue.anywayOnMain {
                    guard let index = self?.images.index(of: image) else { return }
                    self?.images.removeObject(identicalTo: image)
                    self?.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
        
        reloadData()
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(
        _ itemForRepresentedObjectAtcollectionView: NSCollectionView,
        itemForRepresentedObjectAt indexPath: IndexPath
        ) -> NSCollectionViewItem {
        return makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ShareImageCollectionViewItem"),
            for: indexPath
        )
    }
    
    func collectionView(
        _ collectionView: NSCollectionView,
        willDisplay item: NSCollectionViewItem,
        forRepresentedObjectAt
        indexPath: IndexPath
        ) {
        guard
            let item = item as? ShareImageCollectionViewItemMacOS,
            let image = images.object(at: indexPath.item) as? ShareImage
            else { return }
        
        item.set(image: image)
    }
    
    // This dummy method fix collection view crash ¯\_(ツ)_/¯
    func collectionView(
        _ collectionView: NSCollectionView,
        didEndDisplaying item: NSCollectionViewItem,
        forRepresentedObjectAt indexPath: IndexPath
        ) { }
}

#endif
