//
//  Created by martin on 15.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

public protocol ItemNavigatorProtocol {
    func open(url: URL)

    func open(author: Author)

    func open(authorName: String)

    func openFollowing(for user: Author)

    func openConversation(item: Item)

    func openMedia(media: [Media], index: Int)

    func openReply(item: Item)

    func share(item: Item, sourceView: UIView?)

    func accessibilityPresentLinks(linkList: [(text: String, url: URL)], message: String, sourceView: UIView)

    func openMore(item: Item, sourceView: UIView?)

    func showDiscoveryCategories(categories: [DiscoveryCategory], sourceView: UIView)

    func showLogin()
}
