//
//  Created by Martin Hartl on 19.05.19.
//

import UIKit

public extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type) {
        if let nibReusable = T.self as? NibReusable.Type {
            register(nibReusable.nib, forCellReuseIdentifier: T.identifier)
        } else {
            register(T.self, forCellReuseIdentifier: T.identifier)
        }
    }

    func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type) {
        if let nibReusable = T.self as? NibReusable.Type {
            register(nibReusable.nib, forHeaderFooterViewReuseIdentifier: T.identifier)
        } else {
            register(T.self, forHeaderFooterViewReuseIdentifier: T.identifier)
        }
    }

    func dequeueCell<T: UITableViewCell>(ofType: T.Type,
                                         for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue Cell of type \(T.self)")
        }
        return cell
    }

    func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>(ofType: T.Type) -> T {
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T else {
            fatalError("Could not dequeue HeaderFooterView of type \(T.self)")
        }

        return headerFooterView
    }
}
