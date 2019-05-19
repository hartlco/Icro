//
//  Created by Martin Hartl on 19.05.19.
//

import Foundation

public extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        if let nibReusable = T.self as? NibReusable.Type {
            register(nibReusable.nib, forCellWithReuseIdentifier: T.identifier)
        } else {
            register(T.self, forCellWithReuseIdentifier: T.identifier)
        }
    }

    func dequeueCell<T: UICollectionViewCell>(ofType: T.Type,
                                              for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue Cell of type \(T.self)")
        }
        return cell
    }
}
