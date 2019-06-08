//
//  ContentView.swift
//  SettingsUITest
//
//  Created by martin on 07.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import Combine
import SafariServices

class SettingsStore: BindableObject {
    var didChange = PassthroughSubject<SettingsStore, Never>()

    var isWorpressBlog: Bool = false {
        didSet {
            print("did change isWordpressBlog")
            didChange.send(self)
        }
    }

    var wordpressURL = "" {
        didSet {
            didChange.send(self)
        }
    }

    var wordpressUserName = "" {
        didSet {
            didChange.send(self)
        }
    }

    var wordpressPassword = "" {
        didSet {
            didChange.send(self)
        }
    }

}

struct SettingsContentView: View {
    @ObjectBinding var store: SettingsStore

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Wordpress Setup")
                    .font(.headline)
                    .fontWeight(.bold)) {
                        Toggle(isOn: $store.isWorpressBlog) {
                            Text("Post to Wordpress Site")
                        }
                        TextField($store.wordpressURL,
                        placeholder: Text("Wordpress URL"))
                        TextField($store.wordpressUserName,
                                  placeholder: Text("Username"))
                        TextField($store.wordpressPassword,
                                  placeholder: Text("Password"))
                }
            }
            .listStyle(.grouped)
            .navigationBarTitle(Text("Settings"))
        }
    }
}

struct MuteView: View {
    var body: some View {
        return Text("Mute")
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContentView(store: SettingsStore())
    }
}
#endif
