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
import IcroUIKit
import IcroKit

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
    let dismissAction: () -> Void
    let settingsNavigator: SettingsViewNavigator
    @ObjectBinding var store: SettingsStore

    var body: some View {
        NavigationView {
            Form {
                WordpressSection(store: store)
                MicropubSection(store: store)
                AccountSection()
                OtherSection()
                TipJarSection()
            }
            .navigationBarTitle(Text("Settings"))
            .navigationBarItems(leading: Button(action: {
                self.dismissAction()
            }, label: {
                Image(systemName: "gift")
            }))
        }
    }
}

struct WordpressSection: View {
    @ObjectBinding var store: SettingsStore

    var body: some View {
        return Section(header: Text("Wordpress")
            .font(.headline)
            .fontWeight(.bold)) {
                Toggle(isOn: $store.isWorpressBlog) {
                    Text("Post to Wordpress Site")
                }
                if store.isWorpressBlog {
                    TextField($store.wordpressURL,
                              placeholder: Text("Wordpress URL"))
                    TextField($store.wordpressUserName,
                              placeholder: Text("Username"))
                    TextField($store.wordpressPassword,
                              placeholder: Text("Password"))
                        .textContentType(.password)
                } else {
                    EmptyView()
                }
        }
    }
}

struct MicropubSection: View {
    @ObjectBinding var store: SettingsStore

    var body: some View {
        return Section(header: Text("Micropub")
            .font(.headline)
            .fontWeight(.bold)) {
                Toggle(isOn: $store.isWorpressBlog) {
                    Text("Post to Micropub Site")
                }
                if store.isWorpressBlog {
                    TextField($store.wordpressURL,
                              placeholder: Text("Wordpress URL"))
                    TextField($store.wordpressPassword,
                              placeholder: Text("Token"))
                        .textContentType(.password)
                } else {
                    EmptyView()
                }
        }
    }
}

struct OtherSection: View {
    let settingsNavigator = SettingsViewNavigator(userSettings: .shared)
    var body: some View {
        return Section(header: Text("Other")
            .font(.headline)
            .fontWeight(.bold)) {
                NavigationButton(destination: Text("Test")) {
                    Text("Icro Supports")
                }
                NavigationButton(destination: Text("Test")) {
                    Text("Acknowledgements")
                }
                NavigationButton(destination: settingsNavigator.muteView) {
                    Text("Mute")
                }
        }
    }
}

struct AccountSection: View {
    var body: some View {
        Section {
            Button(action: {

            }, label: {
                Text("Logout")
            })
        }
    }
}

struct TipJarSection: View {
    @ObjectBinding var tipJarViewModel = TipJarViewModel()

    var body: some View {
        return Section(header: Text("Tip Jar")
            .font(.headline)
            .fontWeight(.bold)) {
                stateView
                TipJarView2(viewModel: tipJarViewModel)
        }
    }

    private var stateView: AnyView? {
        switch tipJarViewModel.state {
        case .unloaded, .loaded, .cancelled:
            return nil
        case .loading:
            return AnyView(Text("Loading"))
        case .purchasing(let message):
            return AnyView(Text(message))
        case .purchased(let message):
            return AnyView(Text(message))
        case .purchasingError(let error):
            return AnyView(Text(error.text))
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let settingsNavigator = SettingsViewNavigator(userSettings: .shared)
        return SettingsContentView(dismissAction: {},
                            settingsNavigator: settingsNavigator,
                            store: SettingsStore())
    }
}
#endif
