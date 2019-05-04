//
//  Created by Martin Hartl on 04.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import XCTest
@testable import IcroKit

class UserListViewModelTests: XCTestCase {
    func test_load_callsDidStartLoading() {
        let client = MockClient<[Author]>(returnedData: nil, returnedResourceResult: nil)
        let viewModel = UserListViewModel(resource: makeResource(), client: client)
        var didStartLoadingCalled = false
        viewModel.didStartLoading = {
            didStartLoadingCalled = true
        }
        viewModel.load()
        XCTAssert(didStartLoadingCalled == true)
    }

    func test_load_callsDidFinishWithErrorOnError() {
        let client = MockClient<[Author]>(returnedData: nil, returnedResourceResult: nil)
        client.error = NetworkingError.cannotParse
        let viewModel = UserListViewModel(resource: makeResource(), client: client)
        var didFinishWithErrorCalled = false
        viewModel.didFinishWithError = { _ in
            didFinishWithErrorCalled = true
        }
        viewModel.load()
        XCTAssert(didFinishWithErrorCalled == true)
    }

    func test_load_callsDidFinishLoading() {
        let client = MockClient<[Author]>(returnedData: nil,
                                          returnedResourceResult: Result.success(value: makeAuthors()))
        let viewModel = UserListViewModel(resource: makeResource(), client: client)
        var didFinishLoadingCalled = false
        viewModel.didFinishLoading = {
            didFinishLoadingCalled = true
        }
        viewModel.load()
        XCTAssert(didFinishLoadingCalled == true)
    }

    func test_numberOfUsers() {
        let client = MockClient<[Author]>(returnedData: nil,
                                          returnedResourceResult: Result.success(value: makeAuthors()))
        let viewModel = UserListViewModel(resource: makeResource(), client: client)
        viewModel.load()
        XCTAssert(viewModel.numberOfUsers == 2)
    }

    func test_userForRow() {
        let client = MockClient<[Author]>(returnedData: nil,
                                          returnedResourceResult: Result.success(value: makeAuthors()))
        let viewModel = UserListViewModel(resource: makeResource(), client: client)
        viewModel.load()
        XCTAssert(viewModel.user(for: 1).name == "Author 2")
    }

    // MARK: - Test

    private func makeAuthors() -> [Author] {
        let avatarURL = URL(string: "http://google.de")!

        let author1 = Author(name: "Author 1",
                             url: nil,
                             avatar: avatarURL,
                             username: "Author1",
                             bio: nil,
                             followingCount: nil,
                             isFollowing: nil)

        let author2 = Author(name: "Author 2",
                             url: nil,
                             avatar: avatarURL,
                             username: "Author2",
                             bio: nil,
                             followingCount: nil,
                             isFollowing: nil)

        return [author1, author2]
    }

    private func makeResource() -> Resource<[Author]> {
        let resourceURL = URL(string: "http://google.de")!
        return Resource(url: resourceURL, parseJSON: { _ in
            return self.makeAuthors()
        })
    }
}
