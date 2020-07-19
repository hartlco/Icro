//
//  Created by martin on 01.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit
import IcroUIKit

final class ProfileViewConfigurator: NSObject {
    private let itemNavigator: ItemNavigatorProtocol
    private let viewModel: ListViewModel

    init(itemNavigator: ItemNavigatorProtocol,
         viewModel: ListViewModel) {
        self.itemNavigator = itemNavigator
        self.viewModel = viewModel
    }

    func configure(_ view: ProfileTableViewCell, using author: Author) {
        guard let username = author.username,
            let followingCount = author.followingCount else {
                emptyConfig(for: view)
                return
        }

        view.nameLabel.text = author.name
        view.usernameLabel.text = "@" + username
        view.avatarImageView.kf.setImage(with: author.avatar)
        view.profileButton.setTitle((author.url?.absoluteString ?? ""), for: .normal)
        view.profilePressed = { [weak self] in
            if let url = author.url {
                self?.itemNavigator.open(url: url)
            }
        }
        view.bioLabel.text = author.bio

        view.followButton.isEnabled = true
        view.followingButton.isEnabled = true

        view.followPressed = { [weak view] in
            view?.followButton.isEnabled = false
            self.viewModel.toggleFollowForLoadedAuthor()
        }

        view.followingPressed = { [weak self] in
            self?.itemNavigator.openFollowing(for: author)
        }

        view.avatarPressed = { [weak self] in
            let media = Media(url: author.avatar, isVideo: false)
            self?.itemNavigator.openMedia(media: [media], index: 0)
        }

        view.followButton.isHidden = author.isYou

        if let follows = author.isFollowing {
            view.followButton.setTitle(follows ? NSLocalizedString("PROFILEVIEWCONFIGURATOR_UNFOLLOWBUTTON_TITLE", comment: "") :
                NSLocalizedString("PROFILEVIEWCONFIGURATOR_FOLLOWBUTTON_TITLE", comment: ""),
                                       for: .normal)
        } else {
            view.followButton.setTitle("", for: .normal)
        }

        view.followingButton.setTitle(
            String(format: NSLocalizedString("PROFILEVIEWCONFIGURATOR_FOLLOWINGBUTTON_TITLE", comment: ""), followingCount), for: .normal)

        view.followButton.isEnabled = viewModel.barButtonEnabled
        view.followingButton.isEnabled = viewModel.barButtonEnabled
    }

    private func emptyConfig(for cell: ProfileTableViewCell) {
        cell.avatarImageView.image = nil
        cell.usernameLabel.text = ""
        cell.nameLabel.text = ""
        cell.followButton.setTitle("", for: .normal)
        cell.followingButton.setTitle("", for: .normal)
        cell.profileButton.setTitle("", for: .normal)
        cell.bioLabel.text = ""

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
