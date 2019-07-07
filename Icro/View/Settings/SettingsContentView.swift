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

struct SettingsContentView: View {
    let dismissAction: () -> Void
    let settingsNavigator: SettingsViewNavigator
    @ObjectBinding var store: SettingsViewModel

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
                Text("Close")
            }))
        }
    }
}

struct WordpressSection: View {
    @ObjectBinding var store: SettingsViewModel

    var body: some View {
        Section(header: Text("Wordpress")
            .font(.headline)
            .fontWeight(.bold)) {
                Toggle(isOn: $store.isWordpressBlog) {
                    Text("Post to Wordpress Site")
                }
                inputField
        }
    }

    private var inputField: AnyView? {
        if store.isWordpressBlog {
            return AnyView(Group {
                TextField("Wordpress URL", text: $store.wordpressURL)
                TextField("Username", text: $store.wordpressUsername)
                SecureField("Password", text: $store.wordpressPassword)
            })
        } else {
            return nil
        }
    }
}

struct MicropubSection: View {
    @ObjectBinding var store: SettingsViewModel

    var body: some View {
        Section(header: Text("Micropub")
            .font(.headline)
            .fontWeight(.bold)) {
                Toggle(isOn: $store.isMicropubBlog) {
                    Text("Post to Micropub Site")
                }
                inputField
        }
    }

    private var inputField: AnyView? {
        if store.isMicropubBlog {
            return AnyView(Group {
                TextField("Wordpress URL", text: $store.micropubURL)
                SecureField("Token", text: $store.micropubToken)
            })
        } else {
            return nil
        }
    }
}

struct OtherSection: View {
    let settingsNavigator = SettingsViewNavigator(userSettings: .shared)
    var body: some View {
        return Section(header: Text("Other")
            .font(.headline)
            .fontWeight(.bold)) {
                NavigationLink(destination: Text("Test")) {
                    Text("Icro Supports")
                }
                NavigationLink(destination: AcknowledgementView()) {
                    Text("Acknowledgements")
                }
                NavigationLink(destination: settingsNavigator.muteView) {
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
                TipJarView(viewModel: tipJarViewModel)
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
                            store: SettingsViewModel(userSettings: .shared))
    }
}
#endif
