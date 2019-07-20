//
//  Created by martin on 19.07.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import Combine
import IcroKit
import TypedSymbols

final class VerticalTabViewModel: BindableObject {
    private let userSettings: UserSettings

    var didSelectIndex: (Int) -> Void = { _ in }

    init(userSettings: UserSettings = .shared) {
        self.userSettings = userSettings
        self.selectedTab = userSettings.loggedIn ? HorizontalTab(type: .timeline) :
            HorizontalTab(type: .discover)
        updateTabs()
    }

    var willChange = PassthroughSubject<Void, Never>()

    private var selectedTab: HorizontalTab {
        willSet {
            willChange.send()
        }
    }

    private(set)var tabs: [HorizontalTab] = [] {
        willSet {
            willChange.send()
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
            return Image(symbol: .house_fill)
        case .mentions:
            return Image(symbol: .text_bubble_fill)
        case .favorites:
            return Image(symbol: .heart_fill)
        case .discover:
            return Image(symbol: .safari_fill)
        case .user, .username:
            return Image(symbol: .person_fill)
        case .conversation, .photos, .discoverCollection:
            return Image(symbol: .house_fill)
        }
    }
}
