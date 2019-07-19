//
//  Created by martin on 19.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit
import SwiftUI

#if targetEnvironment(UIKitForMac)
import AppKit
#endif

final class AppNavigator {
    private let window: UIWindow
    private let userSettings: UserSettings
    private let loginViewController: UIViewController
    private var tabBarViewController: TabBarViewController?
    private let loginViewModel = LoginViewModel()
    private let toolbarDelegate = ToolbarDelegate()

    init(window: UIWindow,
         userSettings: UserSettings) {
        self.window = window
        self.userSettings = userSettings

        let loginView = LoginView(viewModel: loginViewModel)

        self.loginViewController = UIHostingController(rootView: loginView)

        loginViewModel.didLogin = { [weak self] _ in
            guard let self = self else { return }
            self.loginViewController.dismiss(animated: true, completion: nil)
            self.tabBarViewController?.reload()
        }

        loginViewModel.didDismiss = { [weak self] in
            guard let self = self else { return }
            self.loginViewController.dismiss(animated: true, completion: nil)
        }
    }

    func showLogin() {
        window.rootViewController?.present(loginViewController, animated: true, completion: nil)
    }

    func showComposeViewController() {
        let navController = UINavigationController()
        let viewModel = ComposeViewModel(mode: .post)
        let itemNavigator = ItemNavigator(navigationController: navController, appNavigator: self)
        let navigator = ComposeNavigator(navigationController: navController, viewModel: viewModel)
        let viewController = ComposeViewController(viewModel: viewModel, composeNavigator: navigator, itemNavigator: itemNavigator)
        navController.viewControllers = [viewController]
        tabBarViewController?.present(navController, animated: true, completion: nil)
    }

    func setup() {
        tabBarViewController = TabBarViewController(userSettings: userSettings, appNavigator: self)

        if UIDevice.current.userInterfaceIdiom == .phone {
            window.rootViewController = tabBarViewController
        } else {
            let splitViewController = UISplitViewController()
            let horizontalTabView = HorizontalTabView()
            let hostingController = UIHostingController(rootView: horizontalTabView)
            splitViewController.viewControllers = [hostingController, tabBarViewController!]
            tabBarViewController?.tabBar.isHidden = true
            tabBarViewController?.extendedLayoutIncludesOpaqueBars = true
            splitViewController.preferredDisplayMode = .allVisible
            window.rootViewController = splitViewController
            splitViewController.maximumPrimaryColumnWidth = 84.0
        }

        #if targetEnvironment(UIKitForMac)
        if let windowScene = window.windowScene,
            let titleBar = windowScene.titlebar {

            tabBarViewController?.didSwitchToIndexByCommand = { [weak self] index in
                self?.toolbarDelegate.selectIndex(index)
            }

            toolbarDelegate.didSelectIndex = { [weak self] index in
                guard let self = self else { return }
                self.tabBarViewController?.selectedIndex = index
            }

            toolbarDelegate.showCompose = { [weak self] in
                guard let self = self else { return }
                self.showComposeViewController()
            }
            let toolbar = NSToolbar(identifier: NSToolbar.Identifier("MainToolbar"))
            titleBar.toolbar = toolbar
            toolbar.delegate = toolbarDelegate
            titleBar.titleVisibility = .hidden
        }
        #endif

        if !userSettings.loggedIn {
            tabBarViewController?.select(type: .discover)
        }

        window.tintColor = Color.main
        window.makeKeyAndVisible()
    }

    func logout() {
        tabBarViewController?.reload()
        Item.deleteAllCached()
        userSettings.logout()
    }

    func handleDeeplink(url: URL) {
        let token = url.absoluteString.replacingOccurrences(of: "icro://", with: "")
        loginViewModel.loginString = token
        loginViewModel.login()
    }
}

final class ToolbarDelegate: NSObject {
    private let items: [ListViewModel.ListType] = [
        .timeline,
        .mentions,
        .favorites,
        .discover,
        .username(username: UserSettings.shared.username)
    ]

    private var selectIndexBlock: (Int) -> Void = { _ in }

    #if targetEnvironment(UIKitForMac)
    let segmentedControlIdentifier = NSToolbarItem.Identifier("tabbar")
    let composeIdentifier = NSToolbarItem.Identifier("compose")
    #endif

    var didSelectIndex: ((Int) -> Void) = { _ in }
    var showCompose: () -> Void = { }

    func selectIndex(_ index: Int) {
        selectIndexBlock(index)
    }
}

#if targetEnvironment(UIKitForMac)
extension ToolbarDelegate: NSToolbarDelegate {
    public func toolbar(_ toolbar: NSToolbar,
                        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                        willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        var toolbarItem: NSToolbarItem

        switch itemIdentifier {
        case segmentedControlIdentifier:
            let group = NSToolbarItemGroup(itemIdentifier: segmentedControlIdentifier,
                                           titles: ["Home", "@", "Fav", "Discover", "Profile"],
                                           selectionMode: .selectOne,
                                           labels: ["Home", "@", "Fav", "Discover", "Profile"],
                                           target: self,
                                           action: #selector(didToggle(group:)))

            group.controlRepresentation = NSToolbarItemGroup.ControlRepresentation.expanded
            group.setSelected(true, at: UserSettings.shared.loggedIn ? 0 : 3)
            selectIndexBlock = { index in
                group.setSelected(true, at: index)
            }
            toolbarItem = group
        case NSToolbarItem.Identifier.flexibleSpace:
            toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        case composeIdentifier:
            let item = NSToolbarItem(itemIdentifier: composeIdentifier, barButtonItem: UIBarButtonItem(image: UIImage(named: "compose"),
                                                                                                       style: .plain,
                                                                                                       target: self,
                                                                                                       action: #selector(openNewWindow)))
            toolbarItem = item
        default:
            fatalError()
        }

        return toolbarItem
    }

    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [segmentedControlIdentifier, NSToolbarItem.Identifier.flexibleSpace, composeIdentifier]
    }

    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.flexibleSpace, segmentedControlIdentifier, .flexibleSpace, composeIdentifier]
    }

    private var toolbarImages: [UIImage] {
        return items.map {
            return $0.image ?? UIImage()
        }
    }

    @objc private func didToggle(group: NSToolbarItemGroup) {
        didSelectIndex(group.selectedIndex)
    }

    @objc private func openNewWindow() {
//        let composeType = "co.hartl.icro.compose"
//
//        let userActivity = NSUserActivity(activityType: composeType)
//        userActivity.userInfo = ["ur": "Test"]
//
//        UIApplication.shared.requestSceneSessionActivation(nil,
//                                                           userActivity: userActivity,
//                                                           options: nil,
//                                                           errorHandler: { error in
//
//        })

        showCompose()

    }
}
#endif
