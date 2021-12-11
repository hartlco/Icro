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
        static let layoutSpace: CGFloat = 16.0

        static let avatarImageHeightWidth = 42.0
        static let actionButtonWidth: CGFloat = 120.0
    }

    var isFavorite: Bool = false

    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true

        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        return imageView
    }()

    let attributedLabel: LinkLabel = {
        let label = LinkLabel()
        label.isOpaque = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true

        return label
    }()

    let usernameLabel: UILabel = {
        let label = UILabel()

        label.isOpaque = true
        label.adjustsFontForContentSizeCategory = true
        label.font = Font().name

        return label
    }()

    let atUsernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = Color.secondaryTextColor
        label.isOpaque = true
        label.adjustsFontForContentSizeCategory = true
        label.font = Font().username

        return label
    }()

    var itemID: String?

    var media = [Media]() {
        didSet {
            if media.count == 1 {
                collectionViewHeightConstraint?.constant = 240
            } else if media.count > 1 {
                collectionViewHeightConstraint?.constant = 140
            } else {
                collectionViewHeightConstraint?.constant = 0
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

    private var collectionViewHeightConstraint: NSLayoutConstraint?
    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerClass(cellType: SingleImageCollectionViewCell.self)
        collectionView.allowsSelection = true
        collectionView.layer.cornerRadius = 4.0

        return collectionView
    }()

    private let titleHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Constants.layoutSpace / 2.0
        stackView.alignment = .top
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let usernamesVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    var didTapAvatar: (() -> Void)?
    var didSelectAccessibilityLink :(() -> Void)?
    var didTapMedia: (([Media], Int) -> Void)?
    var didTapReply: (() -> Void)?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupActionButton()
        setupTitleHorizontalStackView()
        setupLinkLabel()
        setupCollectionView()

        updateAppearance()
        let avatarGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(didTapAvatarGestureRecognizer))
        avatarImageView.addGestureRecognizer(avatarGestureRecognizer)
        backgroundColor = Color.backgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    override public func prepareForReuse() {
        media = []
        updateAppearance()
        avatarImageView.image = nil
        isFavorite = false
        super.prepareForReuse()
    }

    private func setupActionButton() {
        contentView.addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.widthAnchor.constraint(equalToConstant: Constants.actionButtonWidth),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            actionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    private func setupCollectionView() {
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self

        contentView.addSubview(imageCollectionView)

        let heightConstraint = imageCollectionView.heightAnchor.constraint(equalToConstant: 140.0)
        self.collectionViewHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            heightConstraint,
            imageCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.layoutSpace),
            imageCollectionView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -Constants.layoutSpace / 4.0),
            imageCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.layoutSpace),
            imageCollectionView.topAnchor.constraint(equalTo: attributedLabel.bottomAnchor, constant: Constants.layoutSpace)
        ])
    }

    private func setupLinkLabel() {
        contentView.addSubview(attributedLabel)

        NSLayoutConstraint.activate([
            attributedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.layoutSpace),
            attributedLabel.topAnchor.constraint(equalTo: titleHorizontalStackView.bottomAnchor, constant: Constants.layoutSpace),
            attributedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.layoutSpace)
        ])
    }

    private func setupTitleHorizontalStackView() {
        contentView.addSubview(titleHorizontalStackView)

        titleHorizontalStackView.addArrangedSubview(avatarImageView)

        usernamesVerticalStackView.addArrangedSubview(usernameLabel)
        usernamesVerticalStackView.addArrangedSubview(atUsernameLabel)
        titleHorizontalStackView.addArrangedSubview(usernamesVerticalStackView)

        NSLayoutConstraint.activate([
            titleHorizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.layoutSpace),
            titleHorizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.layoutSpace),
            titleHorizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.layoutSpace),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarImageHeightWidth),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarImageHeightWidth)
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
