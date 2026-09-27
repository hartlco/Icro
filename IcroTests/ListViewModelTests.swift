//
//  Created by martin on 21.08.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import XCTest
import UIKit
import Settings
import Client
import Style
@testable import Icro
@testable import Client

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
            (Item.discover.urlRequest, "/posts/discover"),
            (Item.media.urlRequest, "/posts/media")
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

    func test_shouldShowProfileHeader_showsNoHeaderForMedia() {
        let viewModel = ListViewModel(type: .media)
        XCTAssert(viewModel.shouldShowProfileHeader == false, "shouldShowProfileHeader true for .media")
    }

    func test_shouldShowProfileHeader_showsNoHeaderForMentions() {
        let viewModel = ListViewModel(type: .mentions)
        XCTAssert(viewModel.shouldShowProfileHeader == false, "shouldShowProfileHeader true for .mentions")
    }

    func test_shouldShowProfileHeader_showsNoHeaderForDiscover() {
        let viewModel = ListViewModel(type: .discover)
        XCTAssert(viewModel.shouldShowProfileHeader == false, "shouldShowProfileHeader true for .discover")
    }

    func testFollowStateChangesOnlyAfterSuccessfulRequest() {
        let author = Author(name: "Taylor",
                            url: nil,
                            avatar: URL(string: "https://example.com/avatar.jpg")!,
                            username: "taylor",
                            bio: nil,
                            followingCount: 4,
                            isFollowing: false)
        let client = FollowClient()
        let viewModel = ListViewModel(type: .user(user: author), client: client)
        var errors = 0
        viewModel.didFinishWithError = { _ in errors += 1 }

        viewModel.toggleFollowForLoadedAuthor()
        viewModel.toggleFollowForLoadedAuthor()
        XCTAssertEqual(client.requestCount, 1)

        client.complete(.failure(NetworkingError.httpStatus(500)))
        XCTAssertEqual(errors, 1)
        XCTAssertEqual(viewModel.author?.isFollowing, false)

        viewModel.toggleFollowForLoadedAuthor()
        client.complete(.success(Empty()))
        XCTAssertEqual(client.requestCount, 2)
        XCTAssertEqual(viewModel.author?.isFollowing, true)
    }

    @MainActor
    func testNarrowPostHeaderKeepsDateReadable() {
        let cell = ItemTableViewCell(style: .default, reuseIdentifier: nil)
        cell.usernameLabel.text = "A very long display name"
        cell.atUsernameLabel.text = "@an_even_longer_username"
        cell.dateLabel.text = "· 20h"
        cell.setContent(NSAttributedString(string: "A short post"))

        let width: CGFloat = 320
        let height = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        cell.contentView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        cell.contentView.layoutIfNeeded()

        XCTAssertGreaterThanOrEqual(cell.dateLabel.bounds.width,
                                    cell.dateLabel.intrinsicContentSize.width - 1)
        XCTAssertLessThan(cell.atUsernameLabel.bounds.width,
                          cell.atUsernameLabel.intrinsicContentSize.width)
        XCTAssertLessThanOrEqual(cell.atUsernameLabel.frame.minX - cell.usernameLabel.frame.maxX, 6)
        let dateFrame = cell.dateLabel.convert(cell.dateLabel.bounds, to: cell.contentView)
        XCTAssertEqual(dateFrame.maxX, width - 14, accuracy: 1)

        let avatarFrame = cell.avatarImageView.convert(cell.avatarImageView.bounds, to: cell.contentView)
        let actionButton = cell.contentView.subviews.compactMap { $0 as? UIButton }.first
        XCTAssertNotNil(actionButton)
        if let actionButton {
            XCTAssertGreaterThanOrEqual(actionButton.frame.minY, avatarFrame.maxY)
            XCTAssertGreaterThan(actionButton.frame.minX, avatarFrame.maxX)
            XCTAssertEqual(actionButton.frame.maxX, width - 14, accuracy: 1)
        }
    }

    @MainActor
    func testPostTimeStaysAtTrailingEdgeWithoutHandle() {
        let cell = ItemTableViewCell(style: .default, reuseIdentifier: nil)
        cell.usernameLabel.text = "Short name"
        cell.atUsernameLabel.isHidden = true
        cell.dateLabel.text = "20h"
        cell.setContent(NSAttributedString(string: "A short post"))

        let width: CGFloat = 390
        let height = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        cell.contentView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        cell.contentView.layoutIfNeeded()

        let dateFrame = cell.dateLabel.convert(cell.dateLabel.bounds, to: cell.contentView)
        XCTAssertEqual(dateFrame.maxX, width - 14, accuracy: 1)
    }
}

final class MicroBlogAPITests: XCTestCase {
    func testDiscoverTopicsComeFromMicroBlogFeedMetadata() throws {
        let response = Data("""
        {"_microblog":{"tagmoji":[
          {"name":"books","title":"books","emoji":"📚","is_featured":true},
          {"name":"meditation","title":"","emoji":"🧘","is_featured":false}
        ]},"items":[]}
        """.utf8)
        let categories = try DiscoveryCategory.all().parse(response).get()

        XCTAssertEqual(DiscoveryCategory.all().urlRequest.url?.absoluteString,
                       "https://micro.blog/posts/discover")
        XCTAssertEqual(categories.map(\.category), ["books", "meditation"])
        XCTAssertEqual(categories.map(\.title), ["books", "meditation"])
        XCTAssertEqual(categories.map(\.isFeatured), [true, false])
    }

    func testPostingOptionsUseMicroBlogConfigAndCategoryAPI() throws {
        let configJSON = Data("""
        {"destination":[{"uid":"https://one.micro.blog/","name":"one.example",
                          "microblog-title":"My Blog"}]}
        """.utf8)
        let configResource = MicroBlogConfiguration.get(token: "abc")
        let config = try configResource.parse(configJSON).get()
        XCTAssertEqual(configResource.urlRequest.url?.absoluteString, "https://micro.blog/micropub?q=config")
        XCTAssertEqual(configResource.urlRequest.value(forHTTPHeaderField: "Authorization"), "Bearer abc")
        XCTAssertEqual(config.destinations.first?.title, "My Blog")

        let destination = try XCTUnwrap(config.destinations.first)
        let categoryResource = MicroBlogCategories.get(token: "abc", destination: destination.uid)
        let components = try XCTUnwrap(URLComponents(url: categoryResource.urlRequest.url!, resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "q" })?.value, "category")
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "mp-destination" })?.value,
                       destination.id)
        XCTAssertEqual(try categoryResource.parse(Data("{\"categories\":[\"Travel\"]}".utf8)).get().categories,
                       ["Travel"])
    }

    func testDraftPostEncodesDestinationAndMultipleCategories() throws {
        let destination = URL(string: "https://one.micro.blog/")!
        let request = MicropubRequestController.postRequest(token: "abc",
                                                             message: "Hello & goodbye",
                                                             destination: destination,
                                                             categories: ["Travel", "Photos"],
                                                             draft: true)
        XCTAssertEqual(request.url?.absoluteString, "https://micro.blog/micropub")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer abc")
        let body = try XCTUnwrap(String(data: request.httpBody!, encoding: .utf8))
        var components = URLComponents()
        components.percentEncodedQuery = body
        let items = try XCTUnwrap(components.queryItems)
        XCTAssertEqual(items.first(where: { $0.name == "content" })?.value, "Hello & goodbye")
        XCTAssertEqual(items.first(where: { $0.name == "mp-destination" })?.value, destination.absoluteString)
        XCTAssertEqual(items.filter { $0.name == "category[]" }.compactMap(\.value), ["Travel", "Photos"])
        XCTAssertEqual(items.first(where: { $0.name == "post-status" })?.value, "draft")
    }

    @MainActor
    func testFailedPublishKeepsComposerReadyToRetry() async {
        let settings = UserSettings(userDefaults: UserDefaults(suiteName: "icro-publish-\(UUID().uuidString)")!)
        settings.token = "abc"
        let viewModel = ComposeViewModel(mode: .post,
                                         userSettings: settings,
                                         client: FailedPublishingClient())
        viewModel.text = "Keep this draft"

        do {
            try await viewModel.post()
            XCTFail("Expected the failed server response to throw")
        } catch NetworkingError.httpStatus(let status) {
            XCTAssertEqual(status, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertFalse(viewModel.uploading)
        XCTAssertTrue(viewModel.composeKeyboardInputViewModel.postButtonEnabled)
        XCTAssertEqual(viewModel.text, "Keep this draft")
    }
}

private final class FailedPublishingClient: Client {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        (Data(), HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!)
    }

    func load<A: Codable>(resource: Resource<A>) async throws -> A {
        fatalError("Unexpected resource request")
    }

    func load<A: Codable>(resource: Resource<A>, completion: @escaping (Result<A, Error>) -> Void) {
        fatalError("Unexpected resource request")
    }
}

private final class FollowClient: Client {
    private var pending: ((Result<Empty, Error>) -> Void)?
    private(set) var requestCount = 0

    func load<A: Codable>(resource: Resource<A>) async throws -> A {
        fatalError("Unexpected async resource request")
    }

    func load<A: Codable>(resource: Resource<A>, completion: @escaping (Result<A, Error>) -> Void) {
        requestCount += 1
        pending = { result in
            switch result {
            case .success(let value): completion(.success(value as! A))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func complete(_ result: Result<Empty, Error>) {
        let completion = pending
        pending = nil
        completion?(result)
    }

    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        fatalError("Unexpected raw network request")
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
