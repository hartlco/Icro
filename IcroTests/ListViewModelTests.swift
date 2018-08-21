//
//  Created by martin on 21.08.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import XCTest

class ListViewModelTests: XCTestCase {
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
