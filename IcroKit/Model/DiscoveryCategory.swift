//
//  DiscoveryCategory.swift
//  IcroKit
//

import Foundation

public struct DiscoveryCategory: Codable, Equatable {
    public let title: String
    public let category: String
    public let emoji: String
    public let isFeatured: Bool
}

public extension DiscoveryCategory {
    init?(dictionary: JSONDictionary) {
        guard let category = dictionary["name"] as? String,
            let emoji = dictionary["emoji"] as? String else {
                return nil
        }

        let title = dictionary["title"] as? String
        self.title = (title?.isEmpty == false ? title : nil) ?? category
        self.category = category
        self.emoji = emoji
        self.isFeatured = dictionary["is_featured"] as? Bool ?? false
    }
}

struct DiscoveryResponse: Codable {
    let categories: [DiscoveryCategory]

    init(categories: [DiscoveryCategory]) {
        self.categories = categories
    }
}
