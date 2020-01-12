//
//  ContentView.swift
//  Icro-Next
//
//  Created by Martin Hartl on 12.01.20.
//  Copyright © 2020 Martin Hartl. All rights reserved.
//

import SwiftUI
import VerticalTabView
import TypedSymbols

struct ContentView: View {
    let viewModel = VerticalTabViewModel(tabs: [VerticalTab(image: Image("play-button"), title: "Profile")],
                                         selectedTab: VerticalTab(image: Image("play-button"), title: "Profile"))

    var body: some View {
        HSplitView {
            VerticalTabView(viewModel: viewModel)
            Text("Hi SwiftUI")
        }
    }

    let tabs = [
        VerticalTab(image: Image("Profile"), title: "Profile")
    ]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
