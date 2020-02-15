//
//  DiscoveryCategoryResource.swift
//  IcroKit
//

import Foundation
import Client
import Settings

// swiftlint:disable line_length
private let discoveryCategoriesResource = URL(string: "https://raw.githubusercontent.com/hartlco/Icro/master/discoverCategories/discoverCategories.json")!

public extension DiscoveryCategory {
    static func all() -> Resource<[DiscoveryCategory]> {
        return Resource<[DiscoveryCategory]>(url: discoveryCategoriesResource,
                                             authorization: .plain(token: UserSettings.shared.token),
                                             parseJSON: { json in
            guard let categories = json as? [JSONDictionary] else { return nil }
            return categories.compactMap(DiscoveryCategory.init(dictionary:))
        })
    }
}
