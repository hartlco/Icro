import SwiftUI
import Combine

@available(iOS 13.0, OSX 10.15, *)
public final class VerticalTabViewModel: ObservableObject {
    public init(tabs: [VerticalTab],
                selectedTab: VerticalTab) {
        self.tabs = tabs
        self.selectedTab = selectedTab
    }

    public var objectWillChange = ObservableObjectPublisher()

    private var selectedTab: VerticalTab {
        willSet {
            objectWillChange.send()
        }
    }

    public let tabs: [VerticalTab]

    public func isSelected(tab: VerticalTab) -> Bool {
        return tab == selectedTab
    }

    @Published private(set) public var selectedIndex = 0

    public func select(tab: VerticalTab) {
        selectedTab = tab
        guard let index = tabs.firstIndex(of: tab) else { return }
        selectedIndex = index
    }

    public func select(index: Int) {
        let tab = tabs[index]
        select(tab: tab)
    }
}

@available(iOS 13.0, OSX 10.15, *)
public struct VerticalTab: Equatable {
    public let image: Image?
    public let title: String

    public init(image: Image?,
                title: String) {
        self.image = image
        self.title = title
    }
}
