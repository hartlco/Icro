//
//  Created by martin on 11.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import Dequeueable

class UserItemTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            usernameLabel.adjustsFontForContentSizeCategory = true
            usernameLabel.font = Font().name
        }
    }
    @IBOutlet weak var atUsernameLabel: UILabel! {
        didSet {
            atUsernameLabel.adjustsFontForContentSizeCategory = true
            atUsernameLabel.font = Font().username
        }
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
        usernameLabel.isOpaque = true
        atUsernameLabel.isOpaque = true
        usernameLabel.backgroundColor = Color.backgroundColor
        atUsernameLabel.backgroundColor = Color.backgroundColor
        usernameLabel.textColor = Color.textColor
        atUsernameLabel.textColor = Color.secondaryTextColor
        backgroundColor = Color.backgroundColor
    }
}
