//
//  Created by martin on 31.03.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import SDWebImage

final class ItemCellConfigurator: NSObject {
    fileprivate let itemNavigator: ItemNavigator

    init(itemNavigator: ItemNavigator) {
        self.itemNavigator = itemNavigator
    }

    func prefetchCells(for items: [Item]) {
        let images = items.map { item in
            item.author.avatar
        }

        for image in images {
            SDWebImageDownloader.shared().downloadImage(with: image, options: [], progress: nil, completed: nil)
        }
    }

    func configure(_ cell: ItemTableViewCell, forDisplaying item: Item) {
        cell.itemID = item.id
        cell.avatarImageView.sd_setImage(with: item.author.avatar)
        cell.usernameLabel.text = item.author.name
        cell.isFavorite = item.isFavorite
        cell.attributedLabel.set(attributedText: item.content)
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
            self?.itemNavigator.openImages(datasource: cell, at: index)
        }
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

class LinkLabel: UILabel {
    var didTapLink: ((URL) -> Void)?
    private var touchRecognizer: UITapGestureRecognizer?

    func set(attributedText: NSAttributedString) {
        self.attributedText = attributedText
        if touchRecognizer == nil {
            touchRecognizer  = UITapGestureRecognizer(target: self, action: #selector(didTapText(recognizer:)))
            addGestureRecognizer(touchRecognizer!)
        }
    }

    @objc private func didTapText(recognizer: UITapGestureRecognizer) {
        guard let text = attributedText else { return }

        text.enumerateAttributes(in: NSRange(location: 0, length: text.length), options: []) { [weak self] (attributes, rane, _) in
            guard let strongSelf = self else { return }

            let links = attributes.filter({ key, _ in
                return key == NSAttributedStringKey(rawValue: "IcroLinkAttribute")
            })

            links.forEach({ _, value in
                if recognizer.didTapAttributedTextInLabel(label: strongSelf, inRange: rane),
                    let url = value as? URL {
                    strongSelf.didTapLink?(url)
                }
            })
        }
    }
}
