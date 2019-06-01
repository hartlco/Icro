//
//  Created by martin on 19.08.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

public struct Author: Codable, Equatable {
    public let name: String
    public let url: URL?
    public let avatar: URL
    public var username: String?
    public var bio: String?
    public var followingCount: Int?
    public var isFollowing: Bool?
    public var isYou = false

    public init(name: String,
                url: URL?,
                avatar: URL,
                username: String?,
                bio: String?,
                followingCount: Int?,
                isFollowing: Bool?,
                isYou: Bool = false) {
        self.url = url
        self.avatar = avatar
        self.username = username
        self.name = name
        self.bio = bio
        self.followingCount = followingCount
        self.isFollowing = isFollowing
        self.isYou = isYou
    }
}

public extension Author {
    init?(dictionary: JSONDictionary) {
        guard let name = dictionary["name"] as? String,
            let avatarURLString = dictionary["avatar"] as? String,
            let avatar = URL(string: avatarURLString) else {
                return nil

        }

        if let urlString = dictionary["url"] as? String,
            let url = URL(string: urlString) {
            self.url = url
        } else {
            self.url = nil
        }

        self.name = name
        self.avatar = avatar

        if let microblog = dictionary["_microblog"] as? JSONDictionary,
            let username = microblog["username"] as? String {
            self.username = username
        } else if let username = dictionary["username"] as? String {
            self.username = username
        } else {
            self.username = nil
        }
    }

    init?(dictionary: JSONDictionary, microBlog: JSONDictionary) {
        self.init(dictionary: dictionary)
        self.bio = microBlog["bio"] as? String
        self.followingCount = microBlog["following_count"] as? Int
        self.username = microBlog["username"] as? String
        self.isFollowing = microBlog["is_following"] as? Bool
        self.isYou = (microBlog["is_you"] as? Bool) ?? false
    }
}
