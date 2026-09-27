//
//  Created by martin on 31.03.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import SafariServices
import AVKit
import SwiftUI
import Settings

final class ItemNavigator: ItemNavigatorProtocol {
    private let navigationController: UINavigationController
    private let userSettings: UserSettings
    private let mainNavigator: MainNavigator
    private var appNavigator: AppNavigator
    private let application: UIApplication
    private let notificationCenter: NotificationCenter

    init(navigationController: UINavigationController,
         appNavigator: AppNavigator,
         userSettings: UserSettings = .shared,
         application: UIApplication = .shared,
         notificationCenter: NotificationCenter) {
        self.navigationController = navigationController
        self.userSettings = userSettings
        self.mainNavigator = MainNavigator(navigationController: navigationController)
        self.appNavigator = appNavigator
        self.application = application
        self.notificationCenter = notificationCenter
    }

    func open(url: URL) {
        if let username = username(from: url) {
            open(authorName: username)
            return
        }

        application.open(url, options: [:], completionHandler: nil)
    }

    func open(author: Author) {
        let viewModel = ListViewModel(type: .user(user: author))
        let viewController = ListViewController(viewModel: viewModel, itemNavigator: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    func open(authorName: String) {
        let viewModel = ListViewModel(type: .username(username: authorName))
        let viewController = ListViewController(viewModel: viewModel, itemNavigator: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    func openFollowing(for user: Author) {
        let viewModel = UserListViewModel(resource: user.followingResource())
        let viewController = VerticalTabAwareHostingController(rootView: UserListView(viewModel: viewModel, itemNavigator: self))
        viewController.setupNavigateBackShortcut(with: notificationCenter)
        navigationController.pushViewController(viewController, animated: true)
        navigationController.navigationBar.isHidden = false
    }

    func openConversation(item: Item) {
        let viewModel = ListViewModel(type: .conversation(item: item))
        let viewController = ListViewController(viewModel: viewModel, itemNavigator: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    func openMedia(media: [Media], index: Int) {
        guard media.indices.contains(index) else { return }
        let gallery = UIHostingController(rootView: MediaGalleryView(media: media, startIndex: index))
        navigationController.present(gallery, animated: true)
    }

    func openReply(item: Item) {
        let viewModel = ComposeViewModel(mode: .reply(item: item))
        let view = ComposeView(viewModel: viewModel)
        let composeViewController = UIHostingController(rootView: view)
        navigationController.present(composeViewController, animated: true, completion: nil)
    }

    func share(item: Item, sourceView: UIView?) {
        let someText = "\(item.author.name): \"\(item.content.string)\""
        let objectsToShare = item.url
        let sharedObjects = [someText, objectsToShare] as [Any]
        let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sourceView

        navigationController.present(activityViewController, animated: true, completion: nil)
    }

    func showLogin() {
        appNavigator.showLogin()
    }

    func accessibilityPresentLinks(linkList: [(text: String, url: URL)], message: String, sourceView: UIView) {
        let linksActionSheet = UIAlertController(title: "Links", message: message, preferredStyle: .actionSheet)

        for value in linkList {
            let linkAction = UIAlertAction(title: value.text, style: .default) { [weak self] _ in
                self?.open(url: value.url)
            }
            linksActionSheet.addAction(linkAction)
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("ITEMNAVIGATOR_MOREALERT_CANCELACTION", comment: ""),
                                         style: .cancel) { _ in
        }
        linksActionSheet.addAction(cancelAction)

        // support iPad
        linksActionSheet.popoverPresentationController?.sourceView = sourceView
        linksActionSheet.popoverPresentationController?.sourceRect = sourceView.bounds

        navigationController.present(linksActionSheet, animated: true, completion: nil)
    }

    func openMore(item: Item, sourceView: UIView?) {
        let alert = UIAlertController(title:
            NSLocalizedString("ITEMNAVIGATOR_MOREALERT_TITLE", comment: ""),
                                      message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("ITEMNAVIGATOR_MOREALERT_CANCELACTION", comment: ""),
                                      style: .cancel,
                                      handler: { _ in
                                        alert.dismiss(animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title:
            String(format: NSLocalizedString("ITEMNAVIGATOR_MOREALERT_MUTEACTION", comment: ""),
                   item.author.username ?? NSLocalizedString("ITEMNAVIGATOR_MOREALERT_MUTEACTION_FALLBACK", comment: "")),
                                      style: .destructive,
                                      handler: { [weak self] _ in
                                        guard let strongSelf = self else { return }

                                        if let username = item.author.username {
                                            strongSelf.userSettings.addToBlacklist(word: username)
                                        }

                                        let blackListViewModel = MuteViewModel(userSettings: strongSelf.userSettings)
                                        let muteView = MuteView(viewModel: blackListViewModel)
                                        let viewController = UIHostingController(rootView: muteView)
                                        strongSelf.navigationController.pushViewController(viewController, animated: true)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("ITEMNAVIGATOR_MOREALERT_GUIDELINEACTION", comment: ""),
                                      style: .default,
                                      handler: { [weak self] _ in
                                        self?.mainNavigator.openCommunityGuidlines()
        }))

        alert.popoverPresentationController?.sourceView = sourceView

        navigationController.present(alert, animated: true, completion: nil)
    }

    func showDiscoveryCategories(categories: [DiscoveryCategory]) {
        let picker = DiscoveryTopicsView(categories: categories, onSelect: { [weak self] category in
            guard let self else { return }
            self.navigationController.dismiss(animated: true) {
                let viewModel = ListViewModel(type: .discoverCollection(category: category))
                let itemNavigator = ItemNavigator(navigationController: self.navigationController,
                                                  appNavigator: self.appNavigator,
                                                  application: self.application,
                                                  notificationCenter: self.notificationCenter)
                let controller = ListViewController(viewModel: viewModel, itemNavigator: itemNavigator)
                self.navigationController.pushViewController(controller, animated: true)
            }
        }, onDismiss: { [weak self] in
            self?.navigationController.dismiss(animated: true)
        })
        let controller = UIHostingController(rootView: picker)
        controller.modalPresentationStyle = .pageSheet
        navigationController.present(controller, animated: true)
    }
}

private struct DiscoveryTopicsView: View {
    let categories: [DiscoveryCategory]
    let onSelect: (DiscoveryCategory) -> Void
    let onDismiss: () -> Void
    @State private var searchText = ""

    private var visibleCategories: [DiscoveryCategory] {
        guard !searchText.isEmpty else { return categories }
        return categories.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    Section("DISCOVER_FEATURED_TOPICS") {
                        TopicRows(topics: visibleCategories.filter(\.isFeatured), onSelect: onSelect)
                    }
                    Section("DISCOVER_MORE_TOPICS") {
                        TopicRows(topics: visibleCategories.filter { !$0.isFeatured }, onSelect: onSelect)
                    }
                } else {
                    TopicRows(topics: visibleCategories, onSelect: onSelect)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("DISCOVER_TOPICS_TITLE")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("SETTINGSVIEWCONTROLLER_CANCELBUTTON_TITLE", action: onDismiss)
                }
            }
        }
    }

}

private struct TopicRows: View {
    let topics: [DiscoveryCategory]
    let onSelect: (DiscoveryCategory) -> Void

    var body: some View {
        ForEach(topics, id: \.category) { topic in
            Button {
                onSelect(topic)
            } label: {
                HStack(spacing: 12) {
                    Text(topic.emoji)
                        .font(.title2)
                    Text(topic.title)
                        .foregroundStyle(.primary)
                }
                .frame(minHeight: 44, alignment: .leading)
            }
        }
    }
}
