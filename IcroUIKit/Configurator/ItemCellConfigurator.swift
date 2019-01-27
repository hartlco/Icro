//
//  Created by martin on 31.03.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import SDWebImage
import IcroKit

public final class ItemCellConfigurator: NSObject {
    fileprivate let itemNavigator: ItemNavigatorProtocol

    public init(itemNavigator: ItemNavigatorProtocol) {
        self.itemNavigator = itemNavigator
    }

    public func configure(_ cell: ItemTableViewCell, forDisplaying item: Item) {
        cell.itemID = item.id
        cell.avatarImageView.sd_setImage(with: item.author.avatar)
        cell.usernameLabel.text = item.author.name
        cell.isFavorite = item.isFavorite
        let attributedString = item.content
        cell.attributedLabel.set(attributedText: attributedString)
        cell.attributedLabel.didTapLink = { [weak self] link in
            self?.itemNavigator.open(url: link)
        }

        cell.imageURLs = item.images
        cell.didTapAvatar = { [weak self] in
            self?.itemNavigator.open(author: item.author)
        }
        cell.faveView.isHidden = true
        cell.timeLabel.text = item.relativeDateString
        cell.atUsernameLabel.text = "@" + (item.author.username ?? "")
        cell.didTapImages = { [weak self] images, index in
            let dataSource = GalleryDataSource(index: index, imageURLs: images)
            self?.itemNavigator.openImages(datasource: dataSource)
        }

        cell.didSelectAccessibilityLink = { [weak self] in
            let linkList = HTMLContent.textLinks(for: attributedString)
            self?.itemNavigator.accessibilityPresentLinks(linkList: linkList, message: attributedString.string, sourceView: cell)
        }

        cell.accessibilityLabel = item.accessibilityContent
        cell.accessibilityCustomActions = accessibilityCustomActions(for: item, cell: cell, attributedContent: attributedString)
    }

    private func accessibilityCustomActions(for item: Item,
                                            cell: ItemTableViewCell,
                                            attributedContent: NSAttributedString?) -> [UIAccessibilityCustomAction]? {
        var accessibilityActions = [UIAccessibilityCustomAction(name: "\(item.author.name), @\(item.author.username!)",
                                                     target: cell,
                                                     selector: #selector(ItemTableViewCell.accessibilityDidTapAvatar))]
        let imageList = item.htmlContent.imageLinks
        if !imageList.isEmpty {
            let accessibilityImagesActionTitle = "Images (\(imageList.count))"
            accessibilityActions.append(UIAccessibilityCustomAction(name: accessibilityImagesActionTitle,
                                                                    target: cell,
                                                                    selector: #selector(ItemTableViewCell.accessibilityDidTapImages)))
        }
        let linkList = HTMLContent.textLinks(for: attributedContent)
        if !linkList.isEmpty {
            let accessibilityLinksActionTitle = "Links (\(linkList.count))"
            accessibilityActions.append(UIAccessibilityCustomAction(name: accessibilityLinksActionTitle,
                                                         target: cell,
                                                         selector: #selector(ItemTableViewCell.accessibilitySelectLink)))
        }
        return accessibilityActions
    }
}
