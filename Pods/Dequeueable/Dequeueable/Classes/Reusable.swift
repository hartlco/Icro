//
//  Created by Martin Hartl on 19.05.19.
//

import UIKit

public protocol Reusable {
    static var identifier: String { get }
}

public extension Reusable where Self: UIView {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}
extension UICollectionViewCell: Reusable {}
