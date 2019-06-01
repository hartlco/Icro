//
//  Created by martin on 18.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

public class GalleryDataSource {
    public let index: Int
    public let media: [Media]

    public var removeAtIndex: (Int) -> Void = { _ in }

    public init(index: Int,
                media: [Media]) {
        self.index = index
        self.media = media
    }
}
