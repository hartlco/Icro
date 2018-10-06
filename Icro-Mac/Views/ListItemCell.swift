//
//  ListItemCell.swift
//  Icro-Mac
//
//  Created by martin on 06.10.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Cocoa
import Kingfisher

class ListItemCell: NSCollectionViewItem {
    static let nib = NSNib(nibNamed: "ListItemCell", bundle: nil)
    static let identifier = NSUserInterfaceItemIdentifier("ListItemCell")

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var contentLabel: NSTextField!    
    @IBOutlet weak var avatarImageView: NSImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
    }
}
