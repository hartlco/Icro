//
//  DiscoveryCategoryManager.swift
//  IcroKit
//

import Foundation

public final class DiscoveryCategoryManager {
    public static let shared = DiscoveryCategoryManager()
    public private(set) var categories = [DiscoveryCategory]()

    private static let cacheKey = "DiscoveryCategoryManager.list"

    private let client: Client

    init(client: Client = URLSession.shared) {
        self.client = client
    }

    public func update() {
        if let cachedCategories = CacheStorage.retrieve(DiscoveryCategoryManager.cacheKey,
                                                        from: .caches,
                                                        as: DiscoveryResponse.self)?.categories {
            categories = cachedCategories
        }

        client.load(resource: DiscoveryCategory.all()) { [weak self] result in
            guard let categories = result.value else { return }
            self?.categories = categories
            let response = DiscoveryResponse(categories: categories)
            CacheStorage.store(response, to: .caches, as: DiscoveryCategoryManager.cacheKey)
        }
    }
}
