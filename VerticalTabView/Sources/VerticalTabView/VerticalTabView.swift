import SwiftUI

@available(iOS 14.0, OSX 10.15, *)
public struct VerticalTabView: View {
    @ObservedObject var viewModel: VerticalTabViewModel

    public init(viewModel: VerticalTabViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            ForEach(viewModel.tabs, id: \VerticalTab.title) { tab in
                Button(action: {
                    self.viewModel.select(tab: tab)
                }, label: {
                    ImageTab(selected: self.viewModel.isSelected(tab: tab),
                             image: tab.image,
                             title: tab.title)
                })
            }
            Spacer()
        }
        .listStyle(SidebarListStyle())
        .background(Color.clear)
    }
}

@available(iOS 13.0, OSX 10.15, *)
struct ImageTab: View {
    var selected: Bool
    var image: Image?
    var title: String

    var body: some View {
        image?
        .resizable()
        .frame(width: 30, height: 30)
        .padding()
        .foregroundColor(selected ? Color.accentColor : .secondary)
        .accessibility(label: Text(title))
    }
}
