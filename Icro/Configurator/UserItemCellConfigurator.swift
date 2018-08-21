//
//  Created by martin on 11.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import SDWebImage

final class UserItemCellConfigurator {
    func configure(cell: UserItemTableViewCell, for user: Author) {
        cell.usernameLabel.text = user.name
        cell.atUsernameLabel.text = "@" + (user.username ?? "")
        cell.avatarImageView.sd_setImage(with: user.avatar)
    }
}
