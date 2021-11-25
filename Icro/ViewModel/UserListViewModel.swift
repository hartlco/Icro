//
//  Created by martin on 11.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Client

final class UserListViewModel: ObservableObject {
    var objectWillChange = ObservableObjectPublisher()

    var users: [Author] {
        if case .loaded(let authors) = state {
            return authors
        }

        return []
    }

    private let resource: Resource<[Author]>
    private let client: Client

    private var state: ViewModelState<[Author]> = .initial {
        willSet {
            objectWillChange.send()
        }
    }

    init(resource: Resource<[Author]>,
         client: Client = URLSession.shared) {
        self.resource = resource
        self.client = client

        load()
    }

    func load() {
        state = .loading
        client.load(resource: resource) { [weak self] users in
            guard let self = self else { return }
            switch users {
            case .failure(let error):
                self.state = .error(error)
            case .success(let value):
                self.state = .loaded(content: value)
            }
        }
    }
}
