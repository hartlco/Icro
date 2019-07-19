//
//  Created by martin on 19.07.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI

struct HorizontalTabView: View {
    @ObjectBinding var viewModel = HorizontalTabViewModel()

    var body: some View {
        VStack(spacing: 20) {
            ForEach(viewModel.tabs, id: \HorizontalTab.title) { tab in
                ImageTab(selected: self.viewModel.isSelected(tab: tab),
                         image: tab.image,
                         title: tab.title)
            }
            Spacer()
        }

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
        .foregroundColor(selected ? Color.accentColor : .secondary)
        .accessibility(label: Text(title))
    }
}
