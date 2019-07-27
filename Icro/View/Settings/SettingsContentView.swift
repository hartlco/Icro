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
    let settingsNavigator: SettingsNavigator
    @ObjectBinding var store: SettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                WordpressSection(store: store)
                MicropubSection(store: store)
                AccountSection(settingsNavigator: settingsNavigator)
                OtherSection(settingsNavigator: settingsNavigator)
                TipJarSection()
            }
            .navigationBarTitle(Text("SETTINGSVIEWCONTROLLER_TITLE"))
            .navigationBarItems(leading: Button(action: {
                self.dismissAction()
            }, label: {
                Text("SETTINGSVIEWCONTROLLER_CANCELBUTTON_TITLE")
            }))
        }
        .navigationViewStyle(.stack)
    }
}

struct WordpressSection: View {
    @ObjectBinding var store: SettingsViewModel

    var body: some View {
        Section(header: Text("SETTINGSVIEWCONTROLLER_BLOGSETUP_TITLE")
            .font(.headline)
            .fontWeight(.bold),
                footer: Text("SETTINGSVIEWCONTROLLER_BLOGINFO_TEXT").lineLimit(nil)) {
                Toggle(isOn: $store.isWordpressBlog) {
                    Text("SETTINGSVIEWCONTROLLER_BLOGSETUPSWITCH_TEXT")
                }
                inputField
        }
    }

    private var inputField: AnyView? {
        if store.isWordpressBlog {
            return AnyView(Group {
                TextField("SETTINGSVIEWCONTROLLER_BLOGURLFIELD_PLACEHOLDER", text: $store.wordpressURL)
                TextField("SETTINGSVIEWCONTROLLER_BLOGUSERNAMEFIELD_PLACEHOLDER", text: $store.wordpressUsername)
                SecureField("SETTINGSVIEWCONTROLLER_BLOGPASSWORDFIELD_PLACEHOLDER", text: $store.wordpressPassword)
            })
        } else {
            return nil
        }
    }
}

struct MicropubSection: View {
    @ObjectBinding var store: SettingsViewModel

    var body: some View {
        Section(header: Text("SETTINGSVIEWCONTROLLER_MICROPUBSETUP_TITLE")
            .font(.headline)
            .fontWeight(.bold),
                footer: Text("SETTINGSVIEWCONTROLLER_MICROPUBINFO_TEXT").lineLimit(nil)) {
                Toggle(isOn: $store.isMicropubBlog) {
                    Text("SETTINGSVIEWCONTROLLER_MICROPUBSETUPSWITCH_TEXT")
                }
                inputField
        }
    }

    private var inputField: AnyView? {
        if store.isMicropubBlog {
            return AnyView(Group {
                TextField("SETTINGSVIEWCONTROLLER_MICROPUBURLFIELD_PLACEHOLDER",
                          text: $store.micropubURL)
                SecureField("SETTINGSVIEWCONTROLLER_MICROPUBTOKENFIELD_PLACEHOLDER",
                            text: $store.micropubToken)
            })
        } else {
            return nil
        }
    }
}

struct OtherSection: View {
    let settingsNavigator: SettingsNavigator
    var body: some View {
        return Section(header: Text("SETTINGSVIEWCONTROLLER_OTHER_TITLE")
            .font(.headline)
            .fontWeight(.bold)) {
                Button(action: {
                    self.settingsNavigator.openSupportMail()
                }, label: {
                    Text("SETTINGSVIEWCONTROLLER_SUPPORTBUTTON_TITLE")
                })
                NavigationLink(destination: settingsNavigator.acknowledgmentsView) {
                    Text("SETTINGSVIEWCONTROLLER_ACKNOWLEDGMENTSBUTTON_TITLE")
                }
                NavigationLink(destination: settingsNavigator.muteView) {
                    Text("SETTINGSVIEWCONTROLLER_BLACKLISTBUTTON_TITLE")
                }
        }
    }
}

struct AccountSection: View {
    let settingsNavigator: SettingsNavigator

    var body: some View {
        Section(header: Text("SETTINGSVIEWCONTROLLER_ACCOUNT_TITLE")
                .font(.headline)
                .fontWeight(.bold)) {
            Button(action: {
                self.settingsNavigator.logout()
            }, label: {
                Text("SETTINGSVIEWCONTROLLER_LOGOUTBUTTON_TITLE")
            })
        }
    }
}

struct TipJarSection: View {
    @ObjectBinding var tipJarViewModel = TipJarViewModel()

    var body: some View {
        return Section(header: Text("IN-APP-PURCHASE-TIP-JAR")
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
            return AnyView(Text("UIVIEWCONTROLLERLOADING_LOADING_TEXT"))
        case .purchasing(let message):
            return AnyView(Text(message))
        case .purchased(let message):
            return AnyView(Text(message))
        case .purchasingError(let error):
            return AnyView(Text(error.text))
        }
    }
}
