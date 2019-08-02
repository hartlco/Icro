//
//  Created by martin on 19.07.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI

struct VerticalTabView: View {
    @ObservedObject var viewModel: VerticalTabViewModel

    var body: some View {
        VStack(spacing: 20) {
            ForEach(viewModel.tabs, id: \HorizontalTab.title) { tab in
                ImageTab(selected: self.viewModel.isSelected(tab: tab),
                         image: tab.image,
                         title: tab.title)
                .onTapGesture {
                    self.viewModel.select(tab: tab)
                }
            }
            Spacer()
        }
        .background(Color.clear)

    }
}

struct ImageTab: View {
    var selected: Bool
    var image: Image
    var title: String

    var body: some View {
        image
        .resizable()
        .frame(width: 30, height: 30)
        .padding()
        .foregroundColor(selected ? Color.accentColor : .secondary)
        .accessibility(label: Text(title))
    }
}
