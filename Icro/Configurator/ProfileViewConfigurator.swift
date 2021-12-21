//
//  Created by martin on 01.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import ImageViewer
import UIKit

final class ProfileViewConfigurator: NSObject {
    private let itemNavigator: ItemNavigatorProtocol
    private let viewModel: ListViewModel

    init(itemNavigator: ItemNavigatorProtocol,
         viewModel: ListViewModel) {
        self.itemNavigator = itemNavigator
        self.viewModel = viewModel
    }

    func configure(_ view: HostingCell<ProfileCellView>, using author: Author, parentViewController: UIViewController) {
        guard let username = author.username,
            let followingCount = author.followingCount else {
                return
        }

        var profileCellView = ProfileCellView(
            avatarURL: author.avatar,
            realname: author.name,
            username: "@" + username,
            aboutText: author.bio ?? "",
            authorURL: author.url?.absoluteString ?? "",
            isOwnProfile: author.isYou,
            isFollowing: author.isFollowing ?? false,
            followingCount: followingCount,
            disabledAllInteractions: !viewModel.barButtonEnabled
        )

        profileCellView.profilePressed = {[weak self] in
            if let url = author.url {
                self?.itemNavigator.open(url: url)
            }
        }

        profileCellView.followPressed = { [weak self] in
            self?.viewModel.toggleFollowForLoadedAuthor()
        }

        profileCellView.followingPressed = { [weak self] in
            self?.itemNavigator.openFollowing(for: author)
        }

        profileCellView.avatarPressed = { [weak self] in
            let media = Media(url: author.avatar, isVideo: false)
            self?.itemNavigator.openMedia(media: [media], index: 0)
        }

        view.set(rootView: profileCellView, parentController: parentViewController)
    }
}
