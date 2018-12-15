//
//  Created by martin on 18.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import ImageViewer
import SDWebImage
import IcroKit

extension GalleryDataSource: GalleryItemsDataSource {
    public func itemCount() -> Int {
        return imageURLs.count
    }

    public func provideGalleryItem(_ index: Int) -> GalleryItem {
        let imageURL = imageURLs[index]

        return GalleryItem.image { completion in
            SDWebImageDownloader().downloadImage(with: imageURL, options: [], progress: nil, completed: { (image, _, _, _) in
                completion(image)
            })
        }
    }
}

extension GalleryDataSource: GalleryItemsDelegate {
    public func removeGalleryItem(at index: Int) {
        removeAtIndex(index)
    }
}
