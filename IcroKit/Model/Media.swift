//
//  Created by martin on 07.04.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation

public struct Media {
    public let url: URL
    public let isVideo: Bool

    public init(url: URL, isVideo: Bool) {
        self.url = url
        self.isVideo = isVideo
    }
}
