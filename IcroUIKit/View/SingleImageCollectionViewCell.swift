//
//  Created by martin on 07.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import Dequeueable

final class SingleImageCollectionViewCell: UICollectionViewCell, NibReusable {
    public static var nib: UINib {
        return UINib(nibName: String(describing: self),
                     bundle: Bundle(for: SingleImageCollectionViewCell.self))
    }

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
