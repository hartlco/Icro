//
//  Created by martin on 06.10.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit_Mac
import Kingfisher

final class ListItemCellConfigurator {
    private let itemNavigator: ItemNavigator

    init(itemNavigator: ItemNavigator) {
        self.itemNavigator = itemNavigator
    }

    func configure(_ cell: ListItemCell, forDisplaying item: Item) {
        cell.nameLabel.stringValue = item.author.name
        if let username = item.author.username {
            cell.usernameLabel.stringValue = "@\(username)"
        } else {
            cell.usernameLabel.stringValue = ""
        }
        
        cell.timeLabel.stringValue = item.relativeDateString
        cell.contentTextView.textStorage?.setAttributedString(item.content)
        cell.avatarImageView.kf.setImage(with: item.author.avatar)
        cell.images = item.images
        
        cell.contentTextView.didTapLink = { [weak self] url in
            guard let self = self else { return }
            self.itemNavigator.openURL(url)
        }

    }
}
