#if os(iOS)
import UIKit

final class ShareImageCollectionViewIOS: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var images = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: "ShareImageCell", for: indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
        ) {
        let index = indexPath.item
        
        guard
            let cell = cell as? ShareImageCollectionCellIOS,
            let image = images.object(at: index) as? ShareImage
            else {
                return
        }
        
        cell.set(image: image)
    }
}

#endif
