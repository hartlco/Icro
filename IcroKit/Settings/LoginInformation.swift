//
//  Created by martin on 26.08.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

public struct LoginInformation: Codable {
    public let token: String
    public let username: String
    public let defaultSite: String

    public init?(json: JSONDictionary) {
        guard let token = json["token"] as? String,
            let username = json["username"] as? String else {
                return nil
        }

        self.token = token
        self.username = username
        self.defaultSite = (json["default_site"] as? String) ?? "micro.blog"
    }
}
