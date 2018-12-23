//
//  Created by martin on 08.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import SDWebImage

public final class ItemTableViewCell: UITableViewCell {
    public static let identifer = "ItemTableViewCell"
    var isFavorite: Bool = false

    @IBOutlet private weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = 20
            avatarImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var attributedLabel: LinkLabel! {
        didSet {
            attributedLabel.isOpaque = true
            attributedLabel.backgroundColor = Color.backgroundColor
        }
    }
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            usernameLabel.isOpaque = true
            usernameLabel.textColor = Color.textColor
            usernameLabel.backgroundColor = Color.backgroundColor
            usernameLabel.adjustsFontForContentSizeCategory = true
            usernameLabel.font = Font().name
        }
    }
    @IBOutlet weak var atUsernameLabel: UILabel! {
        didSet {
            atUsernameLabel.isOpaque = true
            atUsernameLabel.backgroundColor = Color.backgroundColor
            atUsernameLabel.adjustsFontForContentSizeCategory = true
            atUsernameLabel.font = Font().username
        }
    }
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.isOpaque = true
            timeLabel.backgroundColor = Color.backgroundColor
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
            imageCollectionView.register(UINib(nibName: SingleImageCollectionViewCell.identifier,
                                               bundle: Bundle(for: SingleImageCollectionViewCell.self)),
                                         forCellWithReuseIdentifier: SingleImageCollectionViewCell.identifier)
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
        }
    }

    var didTapAvatar: (() -> Void)?
    var didSelectAccessibilityLink :(() -> Void)?
    var didTapImages: (([URL], Int) -> Void)?

    override public func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        isFavorite = false
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        let avatarGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(didTapAvatarGestureRecognizer))
        avatarImageView.addGestureRecognizer(avatarGestureRecognizer)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(asyncInlineImageFinishedLoading),
                                               name: .asyncInlineImageFinishedLoading,
                                               object: nil)
        backgroundColor = Color.backgroundColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func accessibilityDidTapAvatar() {
        didTapAvatar?()
    }

    @objc func accessibilityDidTapImages() {
        didTapImages?(imageURLs, 0)
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
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleImageCollectionViewCell.identifier,
                                                            for: indexPath) as? SingleImageCollectionViewCell else {
            fatalError("Could not deque SingleImageCollectionViewCell")
        }

        let image = imageURLs[indexPath.row]
        cell.imageView.sd_setImage(with: image)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView,
                               didEndDisplaying cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SingleImageCollectionViewCell else { return }
        cell.imageView.sd_cancelCurrentImageLoad()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapImages?(imageURLs, indexPath.row)
    }
}
