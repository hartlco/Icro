//
//  Created by martin on 04.11.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

class LoadMoreTableViewCell: UITableViewCell {
    static let identifier = "LoadMoreTableViewCell"

    var didPressLoadMore: (() -> Void)?

    @IBAction func loadMorePressed(_ sender: Any) {
        didPressLoadMore?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyAppearance()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        applyAppearance()
    }

    private func applyAppearance() {
        backgroundColor = Color.backgroundColor
    }
}
