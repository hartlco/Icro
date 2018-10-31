//
//  ImageViewItem.swift
//  Icro-Mac
//

import Cocoa

class ImageViewItem: NSCollectionViewItem {
    static let nib = NSNib(nibNamed: "ImageViewItem", bundle: nil)
    static let identifier = NSUserInterfaceItemIdentifier("ImageViewItem")

    @IBOutlet weak var cellImageView: NSImageView!

}
