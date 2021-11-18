//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Foundation
import Settings
import Style

let dateFormatter = ISO8601DateFormatter()

public class Empty: Codable {
    public init() { }
}

public class ItemResponse: Codable {
    public let author: Author?
    public let items: [Item]

    public init(author: Author?,
                items: [Item]) {
        self.author = author
        self.items = items
    }
}

extension Item: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public class Item: Codable {
    // swiftlint:disable identifier_name
    public let id: String
    public let htmlContent: HTMLContent

    public lazy var content: NSAttributedString = {
        return htmlContent.attributedStringWithoutImages() ?? NSAttributedString(string: "")
    }()

    public lazy var media: [Media] = {
        let imageMedia = htmlContent.imageLinks.map {
            return Media(url: $0, isVideo: false)
        }

        let videoMedia = htmlContent.videoLinks.map {
            return Media(url: $0, isVideo: true)
        }

        return imageMedia + videoMedia
    }()

    public let url: URL
    // swiftlint:disable identifier_name
    public let date_published: Date

    public lazy var relativeDateString: String = {
        return date_published.timeAgo
    }()

    public lazy var accessibilityContent: String = {
        return accessibilityLabel(for: self, attributedContent: content)
    }()

    public var author: Author
    public var isFavorite: Bool

    public init(id: String,
                htmlContent: HTMLContent,
                url: URL,
                date_published: Date,
                author: Author,
                isFavorite: Bool) {
        self.id = id
        self.htmlContent = htmlContent
        self.url = url
        self.date_published = date_published
        self.author = author
        self.isFavorite = isFavorite
    }

    public func resetContent() {
        content = htmlContent.attributedStringWithoutImages() ?? NSAttributedString(string: "")
        accessibilityContent = accessibilityLabel(for: self, attributedContent: content)
    }
}

extension Item: CustomDebugStringConvertible {
    public var debugDescription: String {
        return id
    }
}

extension Item {
    convenience init?(
        dictionary: JSONDictionary
    ) {
        guard let id = dictionary["id"] as? String,
        let content_html = dictionary["content_html"] as? String,
        let urlString = dictionary["url"] as? String,
        let url = URL(string: urlString),
        let dateString = dictionary["date_published"] as? String,
        let date = dateFormatter.date(from: dateString),
        let authorDictionary = dictionary["author"] as? JSONDictionary,
        let author = Author(dictionary: authorDictionary)
            else {
                return nil
        }

        let fav: Bool
        if let microblog = dictionary["_microblog"] as? JSONDictionary,
            let isFavorite = microblog["is_favorite"] as? Bool {
            fav = isFavorite
        } else {
            fav = false
        }

        self.init(id: id,
                  htmlContent: HTMLContent(
                    rawHTMLString: content_html,
                    stylePreference: .init(useMediumContent: Settings.UserSettings.shared.useMediumContentFont)
                  ),
                  url: url,
                  date_published: date,
                  author: author,
                  isFavorite: fav)

        _ = media
        _ = content
        _ = relativeDateString
        _ = accessibilityContent
    }
}

extension Item: Equatable {
    public static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Item {
    private func accessibilityLabel(for item: Item, attributedContent: NSAttributedString?) -> String {
        var accessibilityLabel = "\(item.author.name): \(item.content.string)"

        for imageDescription in item.htmlContent.imageDescriptions where !imageDescription.isEmpty {
            accessibilityLabel += ", image: \(imageDescription)"
        }

        let imageList = item.htmlContent.imageLinks
        if !imageList.isEmpty {
            accessibilityLabel += ", \(imageList.count)"
            accessibilityLabel += (imageList.count > 1) ? "images" : "image"
        }

        let linkList = HTMLContent.textLinks(for: attributedContent)
        if !linkList.isEmpty {
            accessibilityLabel += ", \(linkList.count)"
            accessibilityLabel += (linkList.count > 1) ? "links" : "link"
        }

        if item.isFavorite {
            accessibilityLabel += ", favorited"
        }

        accessibilityLabel += ", , \(item.relativeDateString)"
        return accessibilityLabel
    }
}
