//
//  Created by martin on 11.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit

final class UserListViewModel {
    var didStartLoading: () -> Void = { }
    var didFinishLoading: () -> Void = { }
    var didFinishWithError: (Error) -> Void = { _ in }

    private var users = [Author]()
    private let resource: Resource<[Author]>
    private let client: Client

    init(resource: Resource<[Author]>,
         client: Client = URLSession.shared) {
        self.resource = resource
        self.client = client
    }

    func load() {
        didStartLoading()
        client.load(resource: resource) { [weak self] users in
            switch users {
            case .error(let error):
                self?.didFinishWithError(error)
            case .success(let value):
                self?.users = value
                self?.didFinishLoading()
            }
        }
    }

    var numberOfUsers: Int {
        return users.count
    }

    func user(for row: Int) -> Author {
        return users[row]
    }
}
