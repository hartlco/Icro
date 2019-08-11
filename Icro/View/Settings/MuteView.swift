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
    @ObservedObject var viewModel: MuteViewModel
    @State private var addedWord = ""

    var body: some View {
        Form {
            Section {
                ForEach(viewModel.words, id: \.self) { word in
                    Text(word)
                    .contextMenu {
                        Button(action: {
                            self.viewModel.remove(word: word)
                        }, label: {
                            Text("Delete")
                        })
                    }
                }
                .onDelete(perform: delete)
            }
            Section(header: Text("BLACKLISTVIEWCONTROLLER_ADDALERT_MESSAGE")) {
                TextField("BLACKLISTVIEWCONTROLLER_ADDALERT_PLACEHOLDER",
                          text: $addedWord) {
                            self.viewModel.add(word: self.addedWord)
                            self.addedWord = ""

                }
            }
        }
        .navigationBarTitle(Text("BLACKLISTVIEWCONTROLLER_TITLE"))
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
