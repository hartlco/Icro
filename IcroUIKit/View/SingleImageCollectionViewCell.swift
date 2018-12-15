//
//  Created by martin on 07.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

class SingleImageCollectionViewCell: UICollectionViewCell {
    static let identifier = "SingleImageCollectionViewCell"

    @IBOutlet weak var imageView: UIImageView!

    override func prepareForReuse() {
        imageView.image = nil
    }
}
