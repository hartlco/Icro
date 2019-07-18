//
//  MuteView.swift
//  Icro
//
//  Created by martin on 22.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import Combine

struct MuteView: View {
    @ObjectBinding var viewModel: MuteViewModel
    @State private var addedWord = ""

    var body: some View {
        Form {
            Section {
                ForEach(viewModel.words.identified(by: \.self)) { word in
                    Text(word)
                    }
                    .onDelete(perform: delete)
            }
            Section(header: Text("Add words/usernames to your mute filter")) {
                TextField("New muted word",
                          text: $addedWord) {
                            self.viewModel.add(word: self.addedWord)
                            self.addedWord = ""

                }
            }
        }
        .navigationBarTitle(Text("Mute"))
    }

    func delete(at offsets: IndexSet) {
        if let first = offsets.first {
            viewModel.remove(at: first)
        }
    }
}

#if DEBUG
struct MuteView_Previews: PreviewProvider {
    static var previews: some View {
        return MuteView(viewModel: MuteViewModel(userSettings: .shared))
    }
}
#endif
