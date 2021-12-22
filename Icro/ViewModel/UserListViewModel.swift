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
    }

    @MainActor func load() async {
        state = .loading

        do {
            let users = try await client.load(resource: resource)
            state = .loaded(content: users)
        } catch let error {
            state = .error(error)
        }
    }
}
