//
//  DiscoveryCategoryResource.swift
//  IcroKit
//

import Foundation

private let discoveryCategoriesResource = URL(string: "https://raw.githubusercontent.com/hartlco/Icro/549acf5d7ae22c00a182cef0f14e1391a3b4cf3f/discoverCategories/discoverCategories.json")!

public extension DiscoveryCategory {
    public static func all() -> Resource<[DiscoveryCategory]> {
        return Resource<[DiscoveryCategory]>(url: discoveryCategoriesResource, parseJSON: { json in
            guard let categories = json as? [JSONDictionary] else { return nil }
            return categories.compactMap(DiscoveryCategory.init(dictionary:))
        })
    }
}
