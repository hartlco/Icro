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
    @State private var modalPresented = false

    @ObservedObject var store: SettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                WordpressSection(store: store)
                MicropubSection(store: store, settingsNavigator: settingsNavigator)
                AccountSection(settingsNavigator: settingsNavigator)
                OtherSection(settingsNavigator: settingsNavigator, store: store)
                TipJarSection()
            }
            .navigationBarTitle(Text("SETTINGSVIEWCONTROLLER_TITLE"))
            .navigationBarItems(leading: Button(action: {
                self.dismissAction()
            }, label: {
                Text("SETTINGSVIEWCONTROLLER_CANCELBUTTON_TITLE")
            }))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WordpressSection: View {
    @ObservedObject var store: SettingsViewModel

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
    @ObservedObject var store: SettingsViewModel
    let settingsNavigator: SettingsNavigator

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
                HStack {
                    TextField("Website URL", text: $store.indieAuthMeURLString)
                        .disableAutocorrection(true)
                        .autocapitalization(UITextAutocapitalizationType.none)
                    Button(action: {
                        self.settingsNavigator.openIndieAuthFlow(for: self.store.indieAuthMeURLString)
                    }, label: {
                        Text("Indie Auth")
                    })
                    .disabled(self.store.indieAuthMeURLString == "")
                }
            })
        } else {
            return nil
        }
    }
}

struct OtherSection: View {
    let settingsNavigator: SettingsNavigator
    @State private var modalPresented = false
    @ObservedObject var store: SettingsViewModel

    var body: some View {
        return Section(header: Text("SETTINGSVIEWCONTROLLER_OTHER_TITLE")
            .font(.headline)
            .fontWeight(.bold)) {
                Button(action: {
                        self.modalPresented = true
                }, label: {
                        Text("SETTINGSVIEWCONTROLLER_SUPPORTBUTTON_TITLE")
                }).sheet(isPresented: self.$modalPresented) {
                    self.settingsNavigator.mailView
                }.disabled(!self.store.canSendMail)
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
    @ObservedObject var tipJarViewModel = TipJarViewModel()

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
