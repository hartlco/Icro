//
//  Created by martin on 18.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

public class GalleryDataSource {
    public let index: Int
    public let imageURLs: [URL]

    public var removeAtIndex: (Int) -> Void = { _ in }

    public init(index: Int,
                imageURLs: [URL]) {
        self.index = index
        self.imageURLs = imageURLs
    }
}
