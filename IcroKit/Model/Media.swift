//
//  Created by martin on 07.04.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation

public struct Media {
    public let url: URL
    public let isVideo: Bool
    public let posterURL: URL?

    public init(url: URL, isVideo: Bool, posterURL: URL? = nil) {
        self.url = url
        self.isVideo = isVideo
        self.posterURL = posterURL
    }
}
