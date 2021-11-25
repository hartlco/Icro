//
//  Created by martin on 19.07.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import Combine
import TypedSymbols
import Settings
import VerticalTabView

extension VerticalTab {
    init(type: ListViewModel.ListType) {
        self = VerticalTab(image: type.swiftUIImage, title: type.title)
    }
}

private extension ListViewModel.ListType {
    var swiftUIImage: Image {
        switch self {
        case .timeline:
            return Image(symbol: Symbol.house_fill)
        case .mentions:
            return Image(symbol: Symbol.text_bubble_fill)
        case .favorites:
            return Image(symbol: Symbol.heart_fill)
        case .discover:
            return Image(symbol: Symbol.safari_fill)
        case .user, .username:
            return Image(symbol: Symbol.person_fill)
        case .conversation, .photos, .discoverCollection:
            return Image(symbol: Symbol.house_fill)
        }
    }
}

extension VerticalTabViewModel {
    convenience init(userSettings: UserSettings) {
        let selectedTab = userSettings.loggedIn ? VerticalTab(type: .timeline) : VerticalTab(type: .discover)

        let tabs = [
            VerticalTab(type: .timeline),
            VerticalTab(type: .mentions),
            VerticalTab(type: .favorites),
            VerticalTab(type: .discover),
            VerticalTab(type: .username(username: userSettings.username))
        ]

        self.init(tabs: tabs, selectedTab: selectedTab)
    }
}
