//
//  Created by martin on 19.07.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import Combine
import IcroKit
import TypedSymbols

final class VerticalTabViewModel: ObservableObject {
    private let userSettings: UserSettings

    var didSelectIndex: (Int) -> Void = { _ in }

    init(userSettings: UserSettings = .shared) {
        self.userSettings = userSettings
        self.selectedTab = userSettings.loggedIn ? HorizontalTab(type: .timeline) :
            HorizontalTab(type: .discover)
        updateTabs()
    }

    var objectWillChange = ObservableObjectPublisher()

    private var selectedTab: HorizontalTab {
        willSet {
            objectWillChange.send()
        }
    }

    private(set)var tabs: [HorizontalTab] = [] {
        willSet {
            objectWillChange.send()
        }
    }

    func isSelected(tab: HorizontalTab) -> Bool {
        return tab == selectedTab
    }

    func select(tab: HorizontalTab) {
        selectedTab = tab
        guard let index = tabs.firstIndex(of: tab) else { return }
        didSelectIndex(index)
    }

    func select(index: Int) {
        let tab = tabs[index]
        select(tab: tab)
    }

    private func updateTabs() {
        tabs = [
            HorizontalTab(type: .timeline),
            HorizontalTab(type: .mentions),
            HorizontalTab(type: .favorites),
            HorizontalTab(type: .discover),
            HorizontalTab(type: .username(username: userSettings.username))
        ]
    }
}

struct HorizontalTab: Equatable {
    let image: Image
    let title: String

    init(type: ListViewModel.ListType) {
        self.image = type.swiftUIImage
        self.title = type.title
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
