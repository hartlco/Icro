//
//  Created by martin on 27.01.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import Dequeueable

final class TipCollectionViewCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var productTitleLabel: UILabel! {
        didSet {
            productTitleLabel.textColor = Color.textColor
        }
    }

    @IBOutlet weak var productPriceLabel: UILabel! {
        didSet {
            productPriceLabel.textColor = Color.main
            productPriceLabel.layer.borderWidth = 1.0
            productPriceLabel.layer.borderColor = Color.main.cgColor
            productPriceLabel.layer.cornerRadius = 4.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 10.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        widthAnchor.constraint(equalToConstant: 120).isActive = true
    }

    //forces the system to do one layout pass
    var isHeightCalculated: Bool = false
}
