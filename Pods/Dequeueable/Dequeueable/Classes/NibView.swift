//
//  Created by Martin Hartl on 19.05.19.
//

import UIKit

public protocol NibView {
    static var nib: UINib { get }
}

public extension NibView where Self: UIView {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}

public protocol NibReusable: Reusable, NibView {}
