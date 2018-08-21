//
//  Created by Martin Hartl on 01/05/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit

class HTMLCollectionViewCell: UICollectionViewCell {
    static let identifier = "HTMLCell"

    @IBOutlet weak var webview: UIWebView!
    // swiftlint:disable line_length
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.bounds.size.height = systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        return layoutAttributes
    }
}
