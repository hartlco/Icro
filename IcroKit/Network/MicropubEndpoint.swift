//
//  Created by martin on 16.09.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

public enum MicropubEndpoint {
    case micropub
    case custom(info: UserSettings.MicropubInfo)

    public var urlString: String {
        switch self {
        case .micropub:
            return "https://micro.blog/micropub"
        case .custom(let info):
            return info.urlString
        }
    }

    public var token: String {
        switch self {
        case .micropub:
            return UserSettings.shared.token
        case .custom(let info):
            return info.micropubToken
        }
    }
}
