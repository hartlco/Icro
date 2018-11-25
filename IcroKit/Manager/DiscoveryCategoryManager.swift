//
//  DiscoveryCategoryManager.swift
//  IcroKit
//

import Foundation

public final class DiscoveryCategoryManager {
    public static let shared = DiscoveryCategoryManager()
    public private(set) var categories = [DiscoveryCategory]()

    private static let cacheKey = "DiscoveryCategoryManager.list"

    public func update() {
        if let cachedCategories = CacheStorage.retrieve(DiscoveryCategoryManager.cacheKey,
                                                        from: .caches,
                                                        as: DiscoveryResponse.self)?.categories {
            categories = cachedCategories
        }

        Webservice().load(resource: DiscoveryCategory.all()) { [weak self] result in
            guard let categories = result.value else { return }
            self?.categories = categories
            let response = DiscoveryResponse(categories: categories)
            CacheStorage.store(response, to: .caches, as: DiscoveryCategoryManager.cacheKey)
        }
    }
}
