//
//  DiscoveryCategoryManager.swift
//  IcroKit
//

import Foundation

public final class DiscoveryCategoryManager {
    public static let shared = DiscoveryCategoryManager()
    public private(set) var categories = [DiscoveryCategory]()

    public func update() {
        Webservice().load(resource: DiscoveryCategory.all()) { [weak self] result in
            guard let categories = result.value else { return }
            self?.categories = categories
        }
    }
}
