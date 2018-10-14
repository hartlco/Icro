//
//  Funcrions.swift
//  IcroKit
//

import Foundation

public func username(from url: URL) -> String? {
    guard url.host == "micro.blog",
        url.pathComponents.count == 2,
        let username = url.pathComponents.last else { return nil }
    return username
}
