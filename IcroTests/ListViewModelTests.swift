//
//  Created by martin on 21.08.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import XCTest
import Settings
@testable import Icro

class ListViewModelTests: XCTestCase {
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
