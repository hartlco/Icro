//
//  DiscoveryCategoryResource.swift
//  IcroKit
//

import Foundation

// swiftlint:disable line_length
private let discoveryCategoriesResource = URL(string: "https://raw.githubusercontent.com/hartlco/Icro/master/discoverCategories/discoverCategories.json")!

public extension DiscoveryCategory {
    public static func all() -> Resource<[DiscoveryCategory]> {
        return Resource<[DiscoveryCategory]>(url: discoveryCategoriesResource, parseJSON: { json in
            guard let categories = json as? [JSONDictionary] else { return nil }
            return categories.compactMap(DiscoveryCategory.init(dictionary:))
        })
    }
}
