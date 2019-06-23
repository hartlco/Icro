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
                            .textContentType(.password)
                }
                OtherSection()
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
