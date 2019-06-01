//
//  Created by martin on 18.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import ImageViewer
import Kingfisher
import IcroKit
import IcroUIKit

extension GalleryDataSource: GalleryItemsDataSource {
    public func itemCount() -> Int {
        return media.count
    }

    public func provideGalleryItem(_ index: Int) -> GalleryItem {
        let mediaItem = media[index]
        return mediaItem.galleryItem()
    }
}

extension GalleryDataSource: GalleryItemsDelegate {
    public func removeGalleryItem(at index: Int) {
        removeAtIndex(index)
    }
}

private extension Media {
    func galleryItem(with manager: KingfisherManager = KingfisherManager.shared) -> GalleryItem {
        switch isVideo {
        case true:
            return GalleryItem.video(fetchPreviewImageBlock: { completion in
                completion(nil)
                let provider = VideoThumbnailImageProvider(url: self.url)
                _ = manager.retrieveImage(with: .provider(provider),
                                          completionHandler: { result in
                                            if case .success(let imageResult) = result {
                                                completion(imageResult.image)
                                            }
                })
            }, videoURL: url)
        case false:
            return GalleryItem.image { completion in
                manager.downloader.downloadImage(with: self.url, completionHandler: { result in
                    if case .success(let imageResult) = result {
                        completion(imageResult.image)
                    }
                })
            }
        }
    }
}
