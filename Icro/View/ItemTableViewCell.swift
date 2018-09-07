//
//  Created by martin on 08.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import SDWebImage
import ImageViewer

extension Notification.Name {
    static let asyncInlineImageFinishedLoading = Notification.Name(rawValue: "asyncInlineImageFinishedLoading")
}

class ItemTableViewCell: UITableViewCell {
    static let identifer = "ItemTableViewCell"
    var isFavorite: Bool = false

    @IBOutlet private weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = 20
            avatarImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var attributedLabel: LinkLabel!
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            usernameLabel.adjustsFontForContentSizeCategory = true
            usernameLabel.font = Font().name
        }
    }
    @IBOutlet weak var atUsernameLabel: UILabel! {
        didSet {
            atUsernameLabel.adjustsFontForContentSizeCategory = true
            atUsernameLabel.font = Font().username
        }
    }
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.adjustsFontForContentSizeCategory = true
            timeLabel.font = Font().username
        }
    }
    @IBOutlet weak var faveView: UIView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    var itemID: String?

    var imageURLs = [URL]() {
        didSet {
            if imageURLs.count != 0 {
                collectionViewHeightConstraint.constant = 140
            } else {
                collectionViewHeightConstraint.constant = 0
            }
            imageCollectionView.reloadData()
        }
    }

    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.register(UINib(nibName: SingleImageCollectionViewCell.identifier, bundle: nil),
                                         forCellWithReuseIdentifier: SingleImageCollectionViewCell.identifier)
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
        }
    }

    var didTapAvatar: (() -> Void)?
    var didSelectAccessibilityLink :(() -> Void)?
    var didTapImages: (([URL], Int) -> Void)?

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        isFavorite = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let avatarGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(didTapAvatarGestureRecognizer))
        avatarImageView.addGestureRecognizer(avatarGestureRecognizer)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(asyncInlineImageFinishedLoading),
                                               name: .asyncInlineImageFinishedLoading,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func accessibilityDidTapAvatar() {
        didTapAvatar?()
    }

    @objc func accessibilitySelectLink() {
        didSelectAccessibilityLink?()
    }

    // MARK: - Private

    @objc private func didTapAvatarGestureRecognizer() {
        didTapAvatar?()
    }

    @objc private func asyncInlineImageFinishedLoading(notification: Notification) {
        guard let idString = notification.userInfo?["id"] as? String,
            idString == itemID else { return }

        attributedLabel.setNeedsDisplay()
        attributedLabel.layoutIfNeeded()
    }
}

extension ItemTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleImageCollectionViewCell.identifier,
                                                            for: indexPath) as? SingleImageCollectionViewCell else {
            fatalError("Could not deque SingleImageCollectionViewCell")
        }

        let image = imageURLs[indexPath.row]
        cell.imageView.sd_setImage(with: image)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SingleImageCollectionViewCell else { return }
        cell.imageView.sd_cancelCurrentImageLoad()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapImages?(imageURLs, indexPath.row)
    }
}

extension ItemTableViewCell: GalleryItemsDataSource {
    func itemCount() -> Int {
        return imageURLs.count
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let imageURL = imageURLs[index]

        return GalleryItem.image { completion in
            SDWebImageDownloader().downloadImage(with: imageURL, options: [], progress: nil, completed: { (image, _, _, _) in
                completion(image)
            })
        }
    }
}
