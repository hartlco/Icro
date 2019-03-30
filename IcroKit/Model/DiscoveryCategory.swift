//
//  DiscoveryCategory.swift
//  IcroKit
//

import Foundation

public struct DiscoveryCategory: Codable {
    public let title: String
    public let category: String
    public let emoji: String
}

public extension DiscoveryCategory {
    init?(dictionary: JSONDictionary) {
        guard let title = dictionary["title"] as? String,
            let category = dictionary["category"] as? String,
            let emoji = dictionary["emoji"] as? String else {
                return nil
        }

        self.title = title
        self.category = category
        self.emoji = emoji
    }
}

struct DiscoveryResponse: Codable {
    let categories: [DiscoveryCategory]

    init(categories: [DiscoveryCategory]) {
        self.categories = categories
    }
}
