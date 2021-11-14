//
//  Created by martin on 07.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import Style

final class SingleImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoPlayImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        videoPlayImage.isHidden = true
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
