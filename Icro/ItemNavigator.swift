//
//  Created by martin on 31.03.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import SafariServices
import IcroKit
import IcroUIKit
import ImageViewer
import AVKit

final class ItemNavigator: ItemNavigatorProtocol {
    private let navigationController: UINavigationController
    private let userSettings: UserSettings
    private let mainNavigator: MainNavigator
    private var appNavigator: AppNavigator

    init(navigationController: UINavigationController,
         appNavigator: AppNavigator,
         userSettings: UserSettings = .shared) {
        self.navigationController = navigationController
        self.userSettings = userSettings
        self.mainNavigator = MainNavigator(navigationController: navigationController)
        self.appNavigator = appNavigator
    }

    func open(url: URL) {
        if let username = username(from: url) {
            open(authorName: username)
            return
        }

        #if targetEnvironment(UIKitForMac)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return
        #endif

        let safariViewController = SFSafariViewController(url: url)
        navigationController.present(safariViewController, animated: true, completion: nil)
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
        let viewController = UserListViewController(viewModel: viewModel, itemNavigator: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    func openConversation(item: Item) {
        let viewModel = ListViewModel(type: .conversation(item: item))
        let viewController = ListViewController(viewModel: viewModel, itemNavigator: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    func openMedia(media: [Media], index: Int) {
        let dataSource = GalleryDataSource(index: index, media: media)
        let gallery = GalleryViewController(startIndex: index,
                                            itemsDataSource: dataSource,
                                            configuration: [GalleryConfigurationItem.deleteButtonMode(.none)])
        navigationController.presentImageGallery(gallery)
    }

    func openReply(item: Item) {
        let navController = UINavigationController()
        let viewModel = ComposeViewModel(mode: .reply(item: item))
        let navigator = ComposeNavigator(navigationController: navController, viewModel: viewModel)
        let viewController = ComposeViewController(viewModel: viewModel,
                                                   composeNavigator: navigator,
                                                   itemNavigator: self)
        navController.viewControllers = [viewController]
        navigationController.present(navController, animated: true, completion: nil)
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

                                        let blackListViewModel = BlacklistViewModel(userSettings: strongSelf.userSettings)
                                        let blackListViewController = BlacklistViewController(viewModel: blackListViewModel,
                                                                                              mainNavigator: strongSelf.mainNavigator)
                                        strongSelf.navigationController.pushViewController(blackListViewController, animated: true)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("ITEMNAVIGATOR_MOREALERT_GUIDELINEACTION", comment: ""),
                                      style: .default,
                                      handler: { [weak self] _ in
                                        self?.mainNavigator.openCommunityGuidlines()
        }))

        alert.popoverPresentationController?.sourceView = sourceView

        navigationController.present(alert, animated: true, completion: nil)
    }

    func showDiscoveryCategories(categories: [DiscoveryCategory], sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for category in categories {
            let action = UIAlertAction(title: "\(category.emoji) - \(category.title)",
            style: .default) { [weak self] _ in
                guard let self = self else { return }
                let viewModel = ListViewModel(type: .discoverCollection(category: category))
                let itemNavigator = ItemNavigator(navigationController: self.navigationController, appNavigator: self.appNavigator)
                let viewController = ListViewController(viewModel: viewModel, itemNavigator: itemNavigator)
                self.navigationController.pushViewController(viewController, animated: true)
            }

            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title:
            NSLocalizedString("ITEMNAVIGATOR_MOREALERT_CANCELACTION", comment: ""),
                                                style: .cancel,
                                                handler: nil))

        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect = sourceView.bounds

        navigationController.present(alertController, animated: true, completion: nil)
    }
}
