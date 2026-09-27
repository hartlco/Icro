import UIKit
import Style
import Kingfisher

public final class ItemTableViewCell: UITableViewCell {
    private enum Layout {
        static let inset: CGFloat = 16
        static let avatarSize: CGFloat = 36
        static let singleMediaHeight: CGFloat = 216
        static let multipleMediaHeight: CGFloat = 146
    }

    var isFavorite = false
    var itemID: String?

    let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.clipsToBounds = true
        view.layer.cornerRadius = Layout.avatarSize / 2
        return view
    }()

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .subheadline)
            .scaledFont(for: .systemFont(ofSize: 16, weight: .semibold))
        label.adjustsFontForContentSizeCategory = true
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let atUsernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let attributedLabel: LinkLabel = {
        let label = LinkLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()

    var media = [Media]() {
        didSet {
            let hasMedia = !media.isEmpty
            imageCollectionView.isHidden = !hasMedia
            collectionViewHeightConstraint.constant = media.count == 1 ? Layout.singleMediaHeight : Layout.multipleMediaHeight
            textBottomConstraint.isActive = !hasMedia
            mediaBottomConstraint.isActive = hasMedia
            imageCollectionView.reloadData()
        }
    }

    var didTapAvatar: (() -> Void)?
    var didSelectAccessibilityLink: (() -> Void)?
    var didTapMedia: (([Media], Int) -> Void)?
    var didTapReply: (() -> Void)?

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .secondaryLabel
        button.accessibilityLabel = NSLocalizedString("ITEMNAVIGATOR_MOREALERT_TITLE", comment: "More actions")
        return button
    }()

    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()

    private let namesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 0
        return stack
    }()

    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 6
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.registerClass(cellType: SingleImageCollectionViewCell.self)
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private var contentTopConstraint: NSLayoutConstraint!
    private var mediaTopConstraint: NSLayoutConstraint!
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    private var textBottomConstraint: NSLayoutConstraint!
    private var mediaBottomConstraint: NSLayoutConstraint!

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        updateAppearance()
        avatarImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapAvatarGestureRecognizer))
        )
    }

    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
        itemID = nil
        attributedLabel.attributedText = nil
        media = []
        isFavorite = false
        didTapAvatar = nil
        didTapMedia = nil
        didTapReply = nil
        didSelectAccessibilityLink = nil
        actionButton.menu = nil
    }

    public override func setSelected(_ selected: Bool, animated: Bool) { }
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) { }

    public func setActionMenu(_ menu: UIMenu) {
        actionButton.menu = menu
        actionButton.showsMenuAsPrimaryAction = true
    }

    public func setContent(_ content: NSAttributedString) {
        attributedLabel.set(attributedText: content)
        let hasText = !content.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        attributedLabel.isHidden = !hasText
        contentTopConstraint.constant = hasText ? 8 : 0
        mediaTopConstraint.constant = hasText ? 10 : 4
    }

    @objc func accessibilityDidTapAvatar() { didTapAvatar?() }
    @objc func accessibilityDidTapImages() { didTapMedia?(media, 0) }
    @objc func accessibilitySelectLink() { didSelectAccessibilityLink?() }

    private func setupLayout() {
        selectionStyle = .none
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self

        namesStack.addArrangedSubview(usernameLabel)
        namesStack.addArrangedSubview(atUsernameLabel)
        titleStack.addArrangedSubview(avatarImageView)
        titleStack.addArrangedSubview(namesStack)
        namesStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        usernameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        atUsernameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        contentView.addSubview(titleStack)
        contentView.addSubview(actionButton)
        contentView.addSubview(attributedLabel)
        contentView.addSubview(imageCollectionView)

        contentTopConstraint = attributedLabel.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 8)
        mediaTopConstraint = imageCollectionView.topAnchor.constraint(equalTo: attributedLabel.bottomAnchor, constant: 10)
        collectionViewHeightConstraint = imageCollectionView.heightAnchor.constraint(equalToConstant: Layout.singleMediaHeight)
        textBottomConstraint = attributedLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        mediaBottomConstraint = imageCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)

        NSLayoutConstraint.activate([
            titleStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.inset),
            titleStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleStack.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -4),
            avatarImageView.widthAnchor.constraint(equalToConstant: Layout.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Layout.avatarSize),
            actionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 40),
            actionButton.heightAnchor.constraint(equalToConstant: 40),
            contentTopConstraint,
            attributedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.inset),
            attributedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.inset),
            mediaTopConstraint,
            imageCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.inset),
            imageCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.inset),
            collectionViewHeightConstraint,
            textBottomConstraint
        ])
    }

    private func updateAppearance() {
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        usernameLabel.textColor = .label
        atUsernameLabel.textColor = .secondaryLabel
        attributedLabel.backgroundColor = .clear
    }

    @objc private func didTapAvatarGestureRecognizer() { didTapAvatar?() }
}

extension ItemTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        media.count
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: SingleImageCollectionViewCell.self, for: indexPath)
        let mediaItem = media[indexPath.row]
        cell.videoPlayImage.isHidden = !mediaItem.isVideo
        if mediaItem.isVideo {
            cell.imageView.kf.setImage(with: VideoThumbnailImageProvider(url: mediaItem.url))
        } else {
            cell.imageView.kf.setImage(with: mediaItem.url)
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapMedia?(media, indexPath.row)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        media.count == 1 ? collectionView.bounds.size : CGSize(width: Layout.multipleMediaHeight,
                                                               height: Layout.multipleMediaHeight)
    }
}
