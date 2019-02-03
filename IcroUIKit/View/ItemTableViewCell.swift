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
        }
    }
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            usernameLabel.isOpaque = true
            usernameLabel.adjustsFontForContentSizeCategory = true
            usernameLabel.font = Font().name
        }
    }
    @IBOutlet weak var atUsernameLabel: UILabel! {
        didSet {
            atUsernameLabel.textColor = Color.secondaryTextColor
            atUsernameLabel.isOpaque = true
            atUsernameLabel.adjustsFontForContentSizeCategory = true
            atUsernameLabel.font = Font().username
        }
    }
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.textColor = Color.secondaryTextColor
            timeLabel.isOpaque = true
            timeLabel.adjustsFontForContentSizeCategory = true
            timeLabel.font = Font().username
        }
    }
    @IBOutlet weak var faveView: UIView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    var itemID: String?

    var imageURLs = [URL]() {
        didSet {
            if imageURLs.count == 1 {
                // 4/3 ratio for single image
                collectionViewHeightConstraint.constant = 240
            } else if imageURLs.count > 1 {
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
        imageURLs = []
        updateAppearance()
        avatarImageView.image = nil
        isFavorite = false
        super.prepareForReuse()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        updateAppearance()
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

    private func updateAppearance() {
        atUsernameLabel.backgroundColor = Color.backgroundColor
        atUsernameLabel.textColor = Color.secondaryTextColor
        usernameLabel.textColor = Color.textColor
        usernameLabel.backgroundColor = Color.backgroundColor
        timeLabel.backgroundColor = Color.backgroundColor
        timeLabel.textColor = Color.secondaryTextColor
        imageCollectionView.backgroundColor = Color.accentSuperLight
        attributedLabel.backgroundColor = Color.backgroundColor
        backgroundColor = Color.backgroundColor
    }
}

extension ItemTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch imageURLs.count {
        case 1:
            return collectionView.frame.size
        case 1...:
            return CGSize(width: 140, height: 140)
        default:
            return CGSize.zero
        }
    }
}
