//
//  Created by martin on 16.09.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

public enum MicropubEndpoint {
    public static let url = URL(string: "https://micro.blog/micropub")!
}

public struct MicroBlogDestination: Codable, Hashable, Identifiable {
    public let uid: URL
    public let name: String
    public let title: String

    public var id: String { uid.absoluteString }

    public init(uid: URL, name: String, title: String) {
        self.uid = uid
        self.name = name
        self.title = title
    }

    init?(dictionary: [String: Any]) {
        guard let uidString = dictionary["uid"] as? String,
              let uid = URL(string: uidString),
              uid.scheme == "https" else { return nil }
        self.init(uid: uid,
                  name: dictionary["name"] as? String ?? uid.host ?? uidString,
                  title: dictionary["microblog-title"] as? String
                    ?? dictionary["name"] as? String
                    ?? uid.host ?? uidString)
    }
}

public struct MicroBlogConfiguration: Codable {
    public let destinations: [MicroBlogDestination]
}

public struct MicroBlogCategories: Codable {
    public let categories: [String]
}
