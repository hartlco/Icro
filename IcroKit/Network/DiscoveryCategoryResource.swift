//
//  DiscoveryCategoryResource.swift
//  IcroKit
//

import Foundation
import Client
private let discoveryCategoriesResource = URL(string: "https://micro.blog/posts/discover")!

public extension DiscoveryCategory {
    static func all() -> Resource<[DiscoveryCategory]> {
        return Resource<[DiscoveryCategory]>(url: discoveryCategoriesResource,
                                             authorization: nil,
                                             parseJSON: { json in
            guard let response = json as? JSONDictionary,
                  let metadata = response["_microblog"] as? JSONDictionary,
                  let categories = metadata["tagmoji"] as? [JSONDictionary] else { return nil }
            return categories.compactMap(DiscoveryCategory.init(dictionary:))
        })
    }
}
