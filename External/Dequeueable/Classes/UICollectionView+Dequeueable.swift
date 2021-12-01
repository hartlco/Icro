//
//  Created by Martin Hartl on 19.05.19.
//

import UIKit

public protocol NibView {
    static var nib: UINib { get }
}

public protocol NibReusable: Reusable, NibView {}

public protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension UITableViewCell: NibReusable {
    public static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView: NibReusable {
    public static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: NibReusable {
    public static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        register(T.nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func registerClass<T: UICollectionViewCell>(cellType: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueCell<T: UICollectionViewCell>(ofType: T.Type,
                                              for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue Cell of type \(T.self)")
        }
        return cell
    }
}

public extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type) {
        register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func registerClass<T: UITableViewCell>(cellType: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type) {
        register(T.nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueCell<T: UITableViewCell>(ofType: T.Type,
                                         for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue Cell of type \(T.self)")
        }
        return cell
    }

    func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>(ofType: T.Type) -> T {
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Could not dequeue HeaderFooterView of type \(T.self)")
        }

        return headerFooterView
    }
}
