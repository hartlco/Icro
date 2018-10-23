//
//  ListItemCell.swift
//  Icro-Mac
//

import Cocoa
import Kingfisher
import IcroKit_Mac

final class ListItemCell: NSCollectionViewItem {
    static let nib = NSNib(nibNamed: "ListItemCell", bundle: nil)
    static let identifier = NSUserInterfaceItemIdentifier("ListItemCell")

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var usernameLabel: NSTextField!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var separatorView: NSView! {
        didSet {
            separatorView.wantsLayer = true
            separatorView.layer?.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        }
    }
    @IBOutlet weak var contentLabel: ContentLabel!

    @IBOutlet weak var avatarImageView: NSImageView! {
        didSet {
            avatarImageView.wantsLayer = true
            avatarImageView.layer?.masksToBounds = true
            avatarImageView.layer?.cornerRadius = 20
        }
    }

    @IBOutlet weak var imageCollectionView: NSCollectionView! {
        didSet {
            imageCollectionView.register(ImageViewItem.nib, forItemWithIdentifier: ImageViewItem.identifier)
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
            imageCollectionView.backgroundColors = [Color.accentSuperLight]
        }
    }

    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    var didDoubleClick: (() -> Void)?
    var images = [URL]() {
        didSet {
            imageCollectionView.reloadData()
            imageCollectionView.isHidden = images.isEmpty
            collectionViewHeight.constant = images.isEmpty ? 0 : 160
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
    }

    @IBAction private func openItemAction(_ sender: Any) {
        didDoubleClick?()
    }

    override var isSelected: Bool {
        willSet {
            if newValue {
                view.layer?.backgroundColor = Color.accentLight.cgColor
            } else {
                view.layer?.backgroundColor = NSColor.white.cgColor
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
    }
}

extension ListItemCell: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell = collectionView.makeItem(withIdentifier: ImageViewItem.identifier, for: indexPath) as? ImageViewItem else {
            fatalError()
        }
        let imageURL = images[indexPath.item]
        cell.cellImageView.kf.setImage(with: imageURL)
        return cell
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        return CGSize(width: 140, height: 140)
    }
}

final class HorizontScrollViewView: NSScrollView {
    override func scrollWheel(with event: NSEvent) {
        if event.scrollingDeltaX != 0 {
            nextResponder?.scrollWheel(with: event)
            return
        }

        super.scrollWheel(with: event)
    }
}

final class ContentLabel: NSTextField {
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }

    var didTapLink: ((URL) -> Void)?
    private var touchRecognizer: NSClickGestureRecognizer?

    func set(attributedText: NSAttributedString) {
        self.attributedStringValue = attributedText
        if touchRecognizer == nil {
            touchRecognizer  = NSClickGestureRecognizer(target: self, action: #selector(didTapText(recognizer:)))
            addGestureRecognizer(touchRecognizer!)
        }
    }

    @objc private func didTapText(recognizer: NSClickGestureRecognizer) {
        attributedStringValue.enumerateAttributes(in: NSRange(location: 0, length: attributedStringValue.length), options: []) { [weak self] (attributes, rane, _) in
            guard let strongSelf = self else { return }

            let links = attributes.filter({ key, _ in
                return key == NSAttributedString.Key(rawValue: "IcroLinkAttribute")
            })

            links.forEach({ _, value in
                if recognizer.didTapAttributedTextInLabel(label: strongSelf, inRange: rane),
                    let url = value as? URL {
                    strongSelf.didTapLink?(url)
                }
            })
        }
    }
}

extension NSClickGestureRecognizer {
    func didTapAttributedTextInLabel(label: ContentLabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedStringValue)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInLabel,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)

        print(NSLocationInRange(indexOfCharacter, targetRange))
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
