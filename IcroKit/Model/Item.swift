//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Foundation

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
    public var hashValue: Int {
        return id.hashValue
    }
}

public class Item: Codable {
    // swiftlint:disable identifier_name
    public let id: String
    public let htmlContent: HTMLContent

    public lazy var content: NSAttributedString = {
        return htmlContent.attributedStringWithoutImages() ?? NSAttributedString(string: "")
    }()

    public lazy var images: [URL] = {
        return htmlContent.imageLinks()
    }()

    public let url: URL
    // swiftlint:disable identifier_name
    public let date_published: Date

    public lazy var relativeDateString: String = {
        return date_published.timeAgo
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
    }
}

extension Item: CustomDebugStringConvertible {
    public var debugDescription: String {
        return id
    }
}

extension Item {
    convenience init?(dictionary: JSONDictionary) {
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
                  htmlContent: HTMLContent(rawHTMLString: content_html, itemID: id),
                  url: url,
                  date_published: date,
                  author: author,
                  isFavorite: fav)

        _ = images
        _ = content
        _ = relativeDateString
    }
}

extension Item: Equatable {
    public static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}
