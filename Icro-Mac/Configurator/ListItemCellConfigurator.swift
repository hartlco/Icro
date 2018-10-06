//
//  Created by martin on 06.10.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit_Mac
import Kingfisher

final class ListItemCellConfigurator {
    func configure(_ cell: ListItemCell, forDisplaying item: Item) {
        cell.nameLabel.stringValue = item.author.name
        cell.contentLabel.stringValue = item.content.string
        cell.avatarImageView.kf.setImage(with: item.author.avatar)
    }
}
