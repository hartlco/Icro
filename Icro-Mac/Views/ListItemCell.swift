//
//  ListItemCell.swift
//  Icro-Mac
//

import Cocoa
import Kingfisher

final class ListItemCell: NSCollectionViewItem {
    static let nib = NSNib(nibNamed: "ListItemCell", bundle: nil)
    static let identifier = NSUserInterfaceItemIdentifier("ListItemCell")

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var contentLabel: NSTextField!    
    @IBOutlet weak var avatarImageView: NSImageView!
    @IBOutlet weak var imageCollectionView: NSCollectionView! {
        didSet {
            imageCollectionView.register(ImageViewItem.nib, forItemWithIdentifier: ImageViewItem.identifier)
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
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

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return CGSize(width: 140, height: 140)
    }


}

final class HorizontScrollViewView: NSScrollView {
    override func scrollWheel(with event: NSEvent) {
        if event.scrollingDeltaY != 0 {
            nextResponder?.scrollWheel(with: event)
            return
        }

        super.scrollWheel(with: event)
    }
}
