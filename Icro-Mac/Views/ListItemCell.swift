//
//  ListItemCell.swift
//  Icro-Mac
//

import Cocoa
import Kingfisher
import IcroKit_Mac

final class ListItemCell: NSTableRowView {
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

    @IBOutlet var contentTextView: HyperlinkTextView! {
        didSet {
            contentTextView.isAutomaticLinkDetectionEnabled = true
            contentTextView.linkTextAttributes = [.foregroundColor: Color.main]
        }
    }

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

    var media = [Media]() {
        didSet {
            imageCollectionView.reloadData()
            imageCollectionView.isHidden = media.isEmpty
            collectionViewHeight.constant = media.isEmpty ? 0 : 160
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
    }

    override func drawSelection(in dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .none {
            Color.accentSuperLight.setFill()
            let selectionPath = NSBezierPath.init(roundedRect: bounds, xRadius: 0, yRadius: 0)
            selectionPath.fill()
        }
    }

    override var interiorBackgroundStyle: NSView.BackgroundStyle {
        return .light
    }
}

extension ListItemCell: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell = collectionView.makeItem(withIdentifier: ImageViewItem.identifier, for: indexPath) as? ImageViewItem else {
            fatalError()
        }
        let imageURL = media[indexPath.item].url
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
        if event.deltaY > 0 {
            nextResponder?.scrollWheel(with: event)
            return
        }

        super.scrollWheel(with: event)
    }
}

class HyperlinkTextView: NSTextView {
    var didTapLink: ((URL) -> Void) = { _ in }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if !openClickedHyperlink(with: event) {
            nextResponder?.nextResponder?.nextResponder?.mouseDown(with: event)
        }
    }

    override func scrollWheel(with event: NSEvent) {
        nextResponder?.nextResponder?.nextResponder?.scrollWheel(with: event)
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        addHyperlinkCursorRects()
    }

    private func addHyperlinkCursorRects() {
        guard let layoutManager = layoutManager, let textContainer = textContainer else {
            return
        }

        let attributedStringValue = attributedString()
        let range = NSRange(location: 0, length: attributedStringValue.length)

        attributedStringValue.enumerateAttribute(.link, in: range) { value, range, _ in
            guard value != nil else {
                return
            }

            let rect = layoutManager.boundingRect(forGlyphRange: range, in: textContainer)
            addCursorRect(rect, cursor: .pointingHand)
        }
    }

    private func openClickedHyperlink(with event: NSEvent) -> Bool {
        let attributedStringValue = attributedString()
        let point = convert(event.locationInWindow, from: nil)
        let characterIndex = characterIndexForInsertion(at: point)

        guard characterIndex < attributedStringValue.length else {
            return false
        }

        let attributes = attributedStringValue.attributes(at: characterIndex, effectiveRange: nil)
        print(attributes)
        guard let url = attributes[.link] as? URL else {
            return false
        }

        didTapLink(url)
        return true
    }
}
