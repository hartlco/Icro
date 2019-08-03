//
//  Created by martin on 19.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit
import SwiftUI

#if targetEnvironment(macCatalyst)
import AppKit
#endif

final class AppNavigator {
    private let window: UIWindow
    private let userSettings: UserSettings
    private let loginViewController: UIViewController
    private lazy var tabBarViewController: TabBarViewController = {
        return TabBarViewController(userSettings: userSettings, appNavigator: self)
    }()
    private let loginViewModel = LoginViewModel()
    private let catalystToolbar = CatalystToolbar()
    private let verticalTabViewModel: VerticalTabViewModel
    private let device: UIDevice

    init(window: UIWindow,
         userSettings: UserSettings,
         device: UIDevice = .current) {
        self.window = window
        self.userSettings = userSettings
        self.device = device

        let loginView = LoginView(viewModel: loginViewModel)

        self.loginViewController = UIHostingController(rootView: loginView)
        self.verticalTabViewModel = VerticalTabViewModel(userSettings: userSettings)

        loginViewModel.didLogin = { [weak self] _ in
            guard let self = self else { return }
            self.loginViewController.dismiss(animated: true, completion: nil)
            self.tabBarViewController.reload()
        }

        loginViewModel.didDismiss = { [weak self] in
            guard let self = self else { return }
            self.loginViewController.dismiss(animated: true, completion: nil)
        }

        tabBarViewController.didSwitchToIndexByCommand = { [weak self] index in
            guard let self = self else { return }
            self.verticalTabViewModel.select(index: index)
        }

        verticalTabViewModel.didSelectIndex = { [weak self] index in
            guard let self = self else { return }
            self.tabBarViewController.selectedIndex = index
        }
    }

    func showLogin() {
        window.rootViewController?.present(loginViewController, animated: true, completion: nil)
    }

    func showComposeViewController() {
        tabBarViewController.present(composeNavigationController, animated: true, completion: nil)
    }

    func setup() {
        if device.userInterfaceIdiom == .phone {
            window.rootViewController = tabBarViewController
        } else {
            let splitViewController = VerticalTabsSplitViewController(verticalTabView: VerticalTabView(viewModel: verticalTabViewModel),
                                                                      tabBarViewController: tabBarViewController)
            window.rootViewController = splitViewController
        }

        setupMacCatalystWindow()

        if !userSettings.loggedIn {
            tabBarViewController.select(type: .discover)
        }

        window.tintColor = Color.main
        window.makeKeyAndVisible()
    }

    func setupComposeWinodw() {
        let navigationController = composeNavigationController
        navigationController.navigationBar.isHidden = true
        window.rootViewController = navigationController
        setupMacCatalystComposeWindow()
        window.tintColor = Color.main
        window.makeKeyAndVisible()
    }

    func logout() {
        tabBarViewController.reload()
        Item.deleteAllCached()
        userSettings.logout()
    }

    func handleDeeplink(url: URL) {
        let token = url.absoluteString.replacingOccurrences(of: "icro://", with: "")
        loginViewModel.loginString = token
        loginViewModel.login()
    }

    func showSettingsView(on presentedController: UIViewController) {
        let settingsNavigator = SettingsNavigator(presentedController: presentedController, appNavigator: self)
        let settingsContentView = SettingsContentView(dismissAction: {
                                                        presentedController.dismiss(animated: true, completion: nil)
        },
                                                      settingsNavigator: settingsNavigator,
                                                      store: SettingsViewModel(userSettings: userSettings))
        presentedController.present(UIHostingController(rootView: settingsContentView), animated: true, completion: nil)
    }

    // MARK: - Private

    private func setupMacCatalystWindow() {
        #if targetEnvironment(macCatalyst)
        if let windowScene = window.windowScene,
            let titleBar = windowScene.titlebar {

            catalystToolbar.showCompose = { [weak self] in
                guard let self = self else { return }
                self.showComposeViewController()
            }
            titleBar.toolbar = catalystToolbar.toolbar
            titleBar.titleVisibility = .hidden
        }
        #endif
    }

    private func setupMacCatalystComposeWindow() {
        #if targetEnvironment(macCatalyst)
        if let windowScene = window.windowScene,
            let titleBar = windowScene.titlebar {
            windowScene.sizeRestrictions?.maximumSize = CGSize(width: 300, height: 250)
            titleBar.toolbar = catalystToolbar.composeToolbar
            titleBar.titleVisibility = .hidden
        }
        #endif
    }

    private var composeNavigationController: UINavigationController {
        let navController = UINavigationController()
        let viewModel = ComposeViewModel(mode: .post)
        let itemNavigator = ItemNavigator(navigationController: navController, appNavigator: self)
        let navigator = ComposeNavigator(navigationController: navController, viewModel: viewModel)
        let viewController = ComposeViewController(viewModel: viewModel, composeNavigator: navigator, itemNavigator: itemNavigator)
        navController.viewControllers = [viewController]
        return navController

    }
}
