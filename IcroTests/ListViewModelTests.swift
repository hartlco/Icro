//
//  Created by martin on 21.08.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import XCTest
import Settings
import Client
import Style
@testable import Icro

class ListViewModelTests: XCTestCase {
    func testAutomaticPaginationLoadsOnceAndOffersRetryAfterFailure() async {
        let defaults = UserDefaults(suiteName: "icro-pagination-\(UUID().uuidString)")!
        let settings = UserSettings(userDefaults: defaults)
        settings.username = "tester"
        settings.token = "test-token"

        let newest = makeItem(id: "2", age: 60)
        let older = makeItem(id: "1", age: 120)
        let client = PagingClient(firstPage: ItemResponse(author: nil, items: [newest]))
        let viewModel = ListViewModel(type: .mentions, userSettings: settings, client: client)
        let initialLoad = expectation(description: "Initial page loaded")
        viewModel.didFinishLoading = { fromCache in
            if !fromCache { initialLoad.fulfill() }
        }
        viewModel.load()
        await fulfillment(of: [initialLoad], timeout: 3)
        viewModel.didFinishLoading = { _ in }

        XCTAssertEqual(viewModel.numberOfItems(), 2)
        XCTAssertTrue(viewModel.loadMore(afterItemAtIndex: 0, automatically: true))
        XCTAssertFalse(viewModel.loadMore(afterItemAtIndex: 0, automatically: true))
        client.completeNextPage(.failure(NetworkingError.cannotParse))
        XCTAssertTrue(viewModel.shouldShowLoadMoreRetry)
        XCTAssertFalse(viewModel.loadMore(afterItemAtIndex: 0, automatically: true))

        XCTAssertTrue(viewModel.loadMore(afterItemAtIndex: 0))
        client.completeNextPage(.success(ItemResponse(author: nil, items: [older])))
        XCTAssertFalse(viewModel.shouldShowLoadMoreRetry)
        XCTAssertEqual(viewModel.numberOfItems(), 3)
    }

    private func makeItem(id: String, age: TimeInterval) -> Item {
        Item(
            id: id,
            htmlContent: HTMLContent(rawHTMLString: "Post \(id)", stylePreference: .init(useMediumContent: false)),
            url: URL(string: "https://example.com/\(id)")!,
            date_published: Date().addingTimeInterval(-age),
            author: Author(name: "Tester", url: nil, avatar: URL(string: "https://example.com/avatar.jpg")!,
                           username: "tester", bio: nil, followingCount: nil, isFollowing: nil),
            isFavorite: false
        )
    }

    func testMicroblogTabRequestsUseCurrentEndpointsAndBearerToken() {
        let settings = UserSettings.shared
        let originalToken = settings.token
        defer { settings.token = originalToken }

        settings.token = "first-token"
        let requests = [
            (Item.all().urlRequest, "/posts/timeline"),
            (Item.mentions.urlRequest, "/posts/mentions"),
            (Item.favorites.urlRequest, "/posts/bookmarks"),
            (Item.discover.urlRequest, "/posts/discover")
        ]

        for (request, path) in requests {
            XCTAssertEqual(request.url?.path, path)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer first-token")
        }

        settings.token = "new-token"
        XCTAssertEqual(Item.all().urlRequest.value(forHTTPHeaderField: "Authorization"), "Bearer new-token")
        XCTAssertEqual(Item.mentions.urlRequest.value(forHTTPHeaderField: "Authorization"), "Bearer new-token")
        XCTAssertEqual(Item.favorites.urlRequest.value(forHTTPHeaderField: "Authorization"), "Bearer new-token")
        XCTAssertEqual(Item.discover.urlRequest.value(forHTTPHeaderField: "Authorization"), "Bearer new-token")
    }

    // MARK: - shouldShowProfileHeader
    func test_shouldShowProfileHeader_showsHeaderForLoggedInUser() {
        let author = Author(name: "Testuser",
                            url: nil,
                            avatar: URL(string: "https://google.de")!,
                            username: nil, bio: nil, followingCount: nil,
                            isFollowing: nil,
                            isYou: true)
        let viewModel = ListViewModel(type: .user(user: author))
        XCTAssert(viewModel.shouldShowProfileHeader == true, "shouldShowProfileHeader false for .user")
    }

    func test_shouldShowProfileHeader_showsHeaderForUsername() {
        let viewModel = ListViewModel(type: .username(username: "Testuser"))
        XCTAssert(viewModel.shouldShowProfileHeader == true, "shouldShowProfileHeader false for .username")
    }

    func test_shouldShowProfileHeader_showsNoHeaderForTimeline() {
        let viewModel = ListViewModel(type: .timeline)
        XCTAssert(viewModel.shouldShowProfileHeader == false, "shouldShowProfileHeader true for .timeline")
    }

    func test_shouldShowProfileHeader_showsNoHeaderForPhotos() {
        let viewModel = ListViewModel(type: .photos)
        XCTAssert(viewModel.shouldShowProfileHeader == false, "shouldShowProfileHeader true for .photos")
    }

    func test_shouldShowProfileHeader_showsNoHeaderForMentions() {
        let viewModel = ListViewModel(type: .mentions)
        XCTAssert(viewModel.shouldShowProfileHeader == false, "shouldShowProfileHeader true for .mentions")
    }

    func test_shouldShowProfileHeader_showsNoHeaderForDiscover() {
        let viewModel = ListViewModel(type: .discover)
        XCTAssert(viewModel.shouldShowProfileHeader == false, "shouldShowProfileHeader true for .discover")
    }
}

private final class PagingClient: Client {
    private let firstPage: ItemResponse
    private var pendingPage: ((Result<ItemResponse, Error>) -> Void)?

    init(firstPage: ItemResponse) {
        self.firstPage = firstPage
    }

    func load<A: Codable>(resource: Resource<A>) async throws -> A {
        firstPage as! A
    }

    func load<A: Codable>(resource: Resource<A>, completion: @escaping (Result<A, Error>) -> Void) {
        pendingPage = { result in
            switch result {
            case .success(let page): completion(.success(page as! A))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func completeNextPage(_ result: Result<ItemResponse, Error>) {
        let completion = pendingPage
        pendingPage = nil
        completion?(result)
    }

    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        fatalError("Unexpected raw network request")
    }
}
