//
//  Created by Martin Hartl on 04.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation

public struct MediaEndpoint: Codable {
    public let mediaEndpoint: URL
}

extension MediaEndpoint {
    init?(dictionary: JSONDictionary) {
        guard let endpointString = dictionary["media-endpoint"] as? String,
            let url = URL(string: endpointString) else { return nil }
        self.mediaEndpoint = url
    }
}
