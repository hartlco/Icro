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
    let itemNavigator: ItemNavigatorProtocol
    let dismissAction: () -> Void

    @ObjectBinding var store: SettingsStore

    private let hartlcoViewModel = ListViewModel(type: .username(username: "hartlco"))

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
                            .textContentType(.password)
                }
                Section(header: Text("Other")
                    .font(.headline)
                    .fontWeight(.bold)) {
                        NavigationButton(destination: MuteView()) {
                            Text("Icro Support")
                        }
                        NavigationButton(destination: MuteView()) {
                            Text("Acknowledgements")
                        }
                }
            }
            .listStyle(.grouped)
            .navigationBarTitle(Text("Settings"))
            .navigationBarItems(leading: Button(action: {
                self.dismissAction()
            }, label: {
                Image(systemName: "gift")
            }))
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
        SettingsContentView(itemNavigator: EmptyItemNavigator(),
                            dismissAction: {},
                            store: SettingsStore())
    }
}

private class EmptyItemNavigator: ItemNavigatorProtocol {
    func showLogin() {

    }

    func open(url: URL) {

    }

    func open(author: Author) {

    }

    func open(authorName: String) {

    }

    func openFollowing(for user: Author) {

    }

    func openConversation(item: Item) {

    }

    func openMedia(media: [Media], index: Int) {

    }

    func openReply(item: Item) {

    }

    func share(item: Item, sourceView: UIView?) {

    }

    func accessibilityPresentLinks(linkList: [(text: String, url: URL)], message: String, sourceView: UIView) {

    }

    func openMore(item: Item, sourceView: UIView?) {

    }

    func showDiscoveryCategories(categories: [DiscoveryCategory], sourceView: UIView) {

    }
}
#endif
