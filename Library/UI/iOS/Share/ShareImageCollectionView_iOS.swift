import UIKit

final class ShareImageCollectionViewIOS: UICollectionView, UICollectionViewDataSource {
    
    private var images = NSMutableArray()
    
    override func awakeFromNib() {
        dataSource = self
    }
    
    func set(images: [ShareImage]) {
        self.images = NSMutableArray(array: images)
        
        images.forEach { [weak self] image in
            image.setOnFail {
                DispatchQueue.safelyOnMain {
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: "ShareImageCell",
            for: indexPath) as? ShareImageCollectionCellIOS,
            let image = images.object(at: index) as? ShareImage
            else {
                return UICollectionViewCell()
        }
        
        
        cell.set(image: image)
        
        return cell
    }
}
