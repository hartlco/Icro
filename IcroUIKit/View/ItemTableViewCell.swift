//
//  Created by martin on 08.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import Style
import AVFoundation
import Kingfisher
import SnapKit
import Settings

public final class ItemTableViewCell: UITableViewCell {
    enum Constants {
        static let actionButtonWidth: CGFloat = 120.0
    }

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

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    var itemID: String?

    var media = [Media]() {
        didSet {
            if media.count == 1 {
                collectionViewHeightConstraint.constant = 240
            } else if media.count > 1 {
                collectionViewHeightConstraint.constant = 140
            } else {
                collectionViewHeightConstraint.constant = 0
            }
            imageCollectionView.reloadData()
        }
    }

    private let actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(symbol: .ellipsis), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = Style.Color.separatorColor

        return button
    }()

    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.registerClass(cellType: SingleImageCollectionViewCell.self)
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
            imageCollectionView.allowsSelection = true
        }
    }

    var didTapAvatar: (() -> Void)?
    var didSelectAccessibilityLink :(() -> Void)?
    var didTapMedia: (([Media], Int) -> Void)?
    var didTapReply: (() -> Void)?

    override public func prepareForReuse() {
        media = []
        updateAppearance()
        avatarImageView.image = nil
        isFavorite = false
        super.prepareForReuse()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        setupActionButton()

        updateAppearance()
        let avatarGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(didTapAvatarGestureRecognizer))
        avatarImageView.addGestureRecognizer(avatarGestureRecognizer)
        backgroundColor = Color.backgroundColor
    }

    private func setupActionButton() {
        addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.widthAnchor.constraint(equalToConstant: Constants.actionButtonWidth),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func accessibilityDidTapAvatar() {
        didTapAvatar?()
    }

    @objc func accessibilityDidTapImages() {
        didTapMedia?(media, 0)
    }

    @objc func accessibilitySelectLink() {
        didSelectAccessibilityLink?()
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        return
    }

    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        return
    }

    public func setActionMenu(_ menu: UIMenu) {
        actionButton.menu = menu
        actionButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - Private

    @objc private func didTapAvatarGestureRecognizer() {
        didTapAvatar?()
    }

    @IBAction private func replyButtonPressed(_ sender: Any) {
        didTapReply?()
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
        return media.count
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: SingleImageCollectionViewCell.self, for: indexPath)

        let mediaItem = media[indexPath.row]

        if mediaItem.isVideo {
            let imageProvider = VideoThumbnailImageProvider(url: mediaItem.url)
            cell.imageView.kf.setImage(with: imageProvider)
            cell.videoPlayImage.isHidden = false
        } else {
            cell.imageView.kf.setImage(with: mediaItem.url)
            cell.videoPlayImage.isHidden = true
        }

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapMedia?(media, indexPath.row)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch media.count {
        case 1:
            return collectionView.frame.size
        case 1...:
            return CGSize(width: 140, height: 140)
        default:
            return CGSize.zero
        }
    }
}
