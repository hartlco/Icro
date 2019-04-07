//
//  Created by martin on 18.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import ImageViewer
import Kingfisher
import IcroKit

extension GalleryDataSource: GalleryItemsDataSource {
    public func itemCount() -> Int {
        return imageURLs.count
    }

    public func provideGalleryItem(_ index: Int) -> GalleryItem {
        let imageURL = imageURLs[index]

        return GalleryItem.image { completion in
            KingfisherManager.shared.downloader.downloadImage(with: imageURL, completionHandler: { result in
                if case .success(let imageResult) = result {
                    completion(imageResult.image)
                }
            })
        }
    }
}

extension GalleryDataSource: GalleryItemsDelegate {
    public func removeGalleryItem(at index: Int) {
        removeAtIndex(index)
    }
}
