//
//  Created by martin on 07.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

class SingleImageCollectionViewCell: UICollectionViewCell {
    static let identifier = "SingleImageCollectionViewCell"

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        updateAppearance()
    }

    override func prepareForReuse() {
        updateAppearance()
        imageView.image = nil
    }

    private func updateAppearance() {
        imageView.backgroundColor = Color.accentLight
    }
}
