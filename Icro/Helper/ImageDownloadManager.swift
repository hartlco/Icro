//
//  Created by martin on 09.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import SDWebImage

class ImageDownloadManager: NSObject {
    private static let resizeValue: CGFloat = 280

    static let shared = ImageDownloadManager()
    let manager = SDWebImageManager.shared()

    override init() {
        super.init()
        manager.delegate = self
    }
}
extension ImageDownloadManager: SDWebImageManagerDelegate {
    func imageManager(_ imageManager: SDWebImageManager, transformDownloadedImage image: UIImage?, with imageURL: URL?) -> UIImage? {
        guard let image = image else { return nil }
        return imageWithImage(sourceImage: image, scaledToWidth: ImageDownloadManager.resizeValue)
    }

    func imageWithImage(sourceImage: UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width

        guard oldWidth > scaledToWidth else { return sourceImage }

        let scaleFactor = scaledToWidth / oldWidth

        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
