//
//  Created by martin on 03.10.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import Client
import Settings

private let pushRegistrationURLStrig = "https://micro.blog/users/push/register"

public struct PushRegistration {
    let token: String
    let enviornment = "production"
    let appName = "Icro"

    public init(token: String) {
        self.token = token
    }
}

extension PushRegistration {
    public func register() -> Resource<Empty> {
        let url = URL(string: pushRegistrationURLStrig + "?device_token=\(token)&push_env=\(enviornment)&app_name=\(appName)")!
        return Resource<Empty>(url: url, httpMethod: .post(nil),
                               authorization: .plain(token: UserSettings.shared.token),
                               parseJSON: { _ in
            return Empty()
        })
    }
}
