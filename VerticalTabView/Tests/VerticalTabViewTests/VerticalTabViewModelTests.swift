import XCTest
@testable import VerticalTabView

final class VerticalTabViewModelTests: XCTestCase {
    var viewModel: VerticalTabViewModel!
    let tabs = [
        VerticalTab(image: nil, title: "tab1"),
        VerticalTab(image: nil, title: "tab2"),
        VerticalTab(image: nil, title: "tab3")
    ]

    override func setUp() {
        viewModel = VerticalTabViewModel(tabs: tabs, selectedTab: tabs[0])
    }

    func test_selectingTab_changesSelectedIndex() {
        viewModel.select(tab: tabs[1])
        XCTAssert(viewModel.selectedIndex == 1, "Selected index not correct")
    }

    func test_isSelected_returnsTrueForSelectedTab() {
        XCTAssert(viewModel.isSelected(tab: tabs[0]), "Is Selected return false for selected tab")
    }

    func test_isSelected_returnsFalseForUnselectedTab() {
        XCTAssert(viewModel.isSelected(tab: tabs[1]) == false, "Is Selected return true for unselected tab")
    }

    func test_selectIndex_selectsTheCorrectTab() {
        viewModel.select(index: 1)
        XCTAssert(viewModel.isSelected(tab: tabs[1]), "Select index did not select the correct tab")
    }

    static var allTests = [
        ("test_selectingTab_changesSelectedIndex", test_selectingTab_changesSelectedIndex),
        ("test_isSelected_returnsTrueForSelectedTab", test_isSelected_returnsTrueForSelectedTab),
        ("test_isSelected_returnsFalseForUnselectedTab", test_isSelected_returnsFalseForUnselectedTab),
        ("test_selectIndex_selectsTheCorrectTab", test_selectIndex_selectsTheCorrectTab)
    ]
}
