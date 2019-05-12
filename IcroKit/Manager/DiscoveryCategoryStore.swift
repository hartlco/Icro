//
//  DiscoveryCategoryManager.swift
//  IcroKit
//

import Foundation

public final class DiscoveryCategoryStore {
    public private(set) var categories = [DiscoveryCategory]()

    private static let cacheKey = "DiscoveryCategoryManager.list"

    private let client: Client

    public init(client: Client = URLSession.shared) {
        self.client = client

        if let cachedCategories = CacheStorage.retrieve(DiscoveryCategoryStore.cacheKey,
                                                        from: .caches,
                                                        as: DiscoveryResponse.self)?.categories {
            categories = cachedCategories
        }
    }

    public func update() {
        client.load(resource: DiscoveryCategory.all()) { [weak self] result in
            guard let categories = result.value else { return }
            self?.categories = categories
            let response = DiscoveryResponse(categories: categories)
            CacheStorage.store(response, to: .caches, as: DiscoveryCategoryStore.cacheKey)
        }
    }
}
