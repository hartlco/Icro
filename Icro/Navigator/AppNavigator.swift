//
//  Created by martin on 19.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import Style
import SwiftUI
import Settings
import VerticalTabView
import MessageUI
import Combine
import Client

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
    private let notificationCenter: NotificationCenter
    private let application: UIApplication
    private var selectedIndexCancellable: AnyCancellable?

    init(window: UIWindow,
         userSettings: UserSettings,
         device: UIDevice = .current,
         notificationCenter: NotificationCenter,
         application: UIApplication) {
        self.window = window
        self.userSettings = userSettings
        self.device = device
        self.notificationCenter = notificationCenter
        self.application = application

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

        selectedIndexCancellable = verticalTabViewModel.$selectedIndex.sink(receiveValue: { [weak self] index in
            guard let self = self else { return }

            self.tabBarViewController.select(index: index)
        })

        self.catalystToolbar.delegate = self
    }

    func showLogin() {
        window.rootViewController?.present(loginViewController, animated: true, completion: nil)
    }

    func showComposeViewController() {
        #if targetEnvironment(macCatalyst)
        guard window.isKeyWindow else { return }
        let activity = NSUserActivity(activityType: UserActivities.compose.rawValue)
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { _ in }
        #else
        tabBarViewController.present(composeNavigationController, animated: true, completion: nil)
        #endif
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
        window.rootViewController = navigationController
        setupMacCatalystComposeWindow()
        window.tintColor = Color.main
        window.makeKeyAndVisible()
    }

    func setupSettingsWindow() {
        let settingsNavigator = SettingsNavigator(presentedController: tabBarViewController,
                                                  appNavigator: self,
                                                  application: application)
        let viewModel = SettingsViewModel(userSettings: userSettings,
                                          canSendMail: MFMailComposeViewController.canSendMail())

        let settingsContentView = SettingsContentView(dismissAction: {

        },
        settingsNavigator: settingsNavigator,
        showsNaviationBarButton: false,
        store: viewModel)

        let navigationController = UINavigationController(rootViewController: UIHostingController(rootView: settingsContentView))
        navigationController.navigationBar.isHidden = true
        window.rootViewController = navigationController
        setupMacCatalystSettingsWindow()
        window.tintColor = Color.main
        window.makeKeyAndVisible()
    }

    func logout() {
        tabBarViewController.reload()
        Item.deleteAllCached()
        userSettings.logout()
    }

    @MainActor func handleDeeplink(url: URL) {
        if url.absoluteString.contains("auth") {
            handleIndieAuthTokenCallback(url: url)
            return
        }

        let token = url.absoluteString.replacingOccurrences(of: "icro://", with: "")
        loginViewModel.loginString = token
        loginViewModel.login()
    }

    func showSettingsView(on presentedController: UIViewController) {
        #if targetEnvironment(macCatalyst)
        guard window.isKeyWindow else { return }
        let activity = NSUserActivity(activityType: UserActivities.settings.rawValue)
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { _ in }
        #else

        let settingsNavigator = SettingsNavigator(presentedController: presentedController,
                                                  appNavigator: self,
                                                  application: application)
        let viewModel = SettingsViewModel(userSettings: userSettings,
                                          canSendMail: MFMailComposeViewController.canSendMail())

        let settingsContentView = SettingsContentView(dismissAction: {
            presentedController.dismiss(animated: true, completion: nil)
        },
        settingsNavigator: settingsNavigator,
        showsNaviationBarButton: true,
        store: viewModel)
        presentedController.present(UIHostingController(rootView: settingsContentView), animated: true, completion: nil)
        #endif
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

    private func setupMacCatalystSettingsWindow() {
        #if targetEnvironment(macCatalyst)
        if let windowScene = window.windowScene,
            let titleBar = windowScene.titlebar {
            windowScene.sizeRestrictions?.maximumSize = CGSize(width: 900, height: 900)
            titleBar.toolbar = catalystToolbar.composeToolbar
            titleBar.titleVisibility = .hidden
        }
        #endif
    }

    private var composeNavigationController: UIViewController {
        let viewModel = ComposeViewModel(mode: .post)
        let view = ComposeView(viewModel: viewModel)

        let viewController = UIHostingController(rootView: view)
        return viewController

    }

    private func handleIndieAuthTokenCallback(url: URL) {
        guard let meURL = URL(string: userSettings.indieAuthMeURLString),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?[0],
            let codeValue = code.value else { return }

        IndieAuth.makeTokenRequest(forEndpoint: IndieAuth.Constants.tokenURL,
                                   meUrl: meURL,
                                   code: codeValue,
                                   redirectURI: IndieAuth.Constants.callback,
                                   clientId: IndieAuth.Constants.clientIDURL.absoluteString) { (_, _, accessToken) in
            DispatchQueue.main.async {
                self.userSettings.micropubToken = accessToken
            }
        }
    }
}

extension AppNavigator: CatalystToolbarDelegate {
    func didRequestToOpenCompose() {
        showComposeViewController()
    }
}
