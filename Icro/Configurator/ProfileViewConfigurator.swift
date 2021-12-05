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
                emptyConfig(for: view)
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

    private func emptyConfig(for cell: HostingCell<ProfileCellView>) {
//        cell.avatarImageView.image = nil
//        cell.usernameLabel.text = ""
//        cell.nameLabel.text = ""
//        cell.followButton.setTitle("", for: .normal)
//        cell.followingButton.setTitle("", for: .normal)
//        cell.profileButton.setTitle("", for: .normal)
//        cell.bioLabel.text = ""

    }
}

private class AuthorImageGalleryDataSource: GalleryItemsDataSource {
    let author: Author

    init(author: Author) {
        self.author = author
    }

    func itemCount() -> Int {
        return 1
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return GalleryItem.image { completion in
//            KingfisherManager.shared.downloader.downloadImage(with: self.author.avatar, completionHandler: { result in
//                switch result {
//                case .success(let imageLoadingResult):
//                    DispatchQueue.main.async {
//                        completion(imageLoadingResult.image)
//                    }
//                default:
//                    return
//                }
//            })
        }
    }
}
