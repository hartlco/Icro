//
//  Created by martin on 11.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

final class UserListViewModel {
    var didStartLoading: () -> Void = { }
    var didFinishLoading: () -> Void = { }
    var didFinishWithError: (Error) -> Void = { _ in }

    private var users = [Author]()
    private let resource: Resource<[Author]>

    init(resource: Resource<[Author]>) {
        self.resource = resource
    }

    func load() {
        didStartLoading()
        Webservice().load(resource: resource) { [weak self] users in
            switch users {
            case .error(let error):
                self?.didFinishWithError(error)
            case .result(let value):
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
