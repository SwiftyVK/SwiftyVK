import UIKit

final class ShareImageCollectionViewIOS: UICollectionView, UICollectionViewDataSource {
    
    private var separator: UIView?
    private var images = [String: Data]()
    
    
    override func awakeFromNib() {
        dataSource = self
    }
    
    func set(images: [String: Data]) {
        self.images = images
        reloadData()
        
        separator = UIView()
        separator?.backgroundColor = UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1)
        
        separator.flatMap {
            addSubview($0)
            bringSubview(toFront: $0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: "ShareImageCell",
            for: indexPath) as? ShareImageCollectionCellIOS
            else {
                return UICollectionViewCell()
        }
        
        let id = Array(images.keys)[index]
        let image = Array(images.values)[index]
        
        cell.set(id: id, image: image)
        
        return cell
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        separator?.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: contentSize.width,
//            height: 1 / UIScreen.main.nativeScale
//        )
//    }
}
