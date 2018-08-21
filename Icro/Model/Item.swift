//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Foundation

let dateFormatter = ISO8601DateFormatter()

class Empty: Codable { }

class ItemResponse: Codable {
    let author: Author?
    let items: [Item]

    init(author: Author?,
         items: [Item]) {
        self.author = author
        self.items = items
    }
}

extension Item: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}

class Item: Codable {
    // swiftlint:disable identifier_name
    let id: String
    let htmlContent: HTMLContent

    lazy var content: NSAttributedString = {
        return htmlContent.attributedStringWithoutImages() ?? NSAttributedString(string: "")
    }()

    lazy var images: [URL] = {
        return htmlContent.imageLinks()
    }()

    let url: URL
    // swiftlint:disable identifier_name
    let date_published: Date

    lazy var relativeDateString: String = {
        return date_published.timeAgo
    }()

    var author: Author
    var isFavorite: Bool

    init(id: String,
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

    func resetContent() {
        content = htmlContent.attributedStringWithoutImages() ?? NSAttributedString(string: "")
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
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}
