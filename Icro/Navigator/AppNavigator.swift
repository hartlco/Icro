//
//  Created by martin on 19.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

#if targetEnvironment(UIKitForMac)
import AppKit
#endif

final class AppNavigator {
    private let window: UIWindow
    private let userSettings: UserSettings
    private let loginViewController: LoginViewController
    private var tabBarViewController: TabBarViewController?
    private let loginViewModel = LoginViewModel()

    init(window: UIWindow,
         userSettings: UserSettings) {
        self.window = window
        self.userSettings = userSettings

        self.loginViewController = LoginViewController(viewModel: loginViewModel)

        loginViewModel.didLogin = { [weak self] _ in
            guard let self = self else { return }
            self.loginViewController.dismiss(animated: true, completion: nil)
            self.tabBarViewController?.reload()
        }
    }

    func showLogin() {
        let navigationController = UINavigationController(rootViewController: loginViewController)
        window.rootViewController?.present(navigationController, animated: true, completion: nil)
    }

    func setup() {
        tabBarViewController = TabBarViewController(userSettings: userSettings, appNavigator: self)
        window.rootViewController = tabBarViewController

        if !userSettings.loggedIn {
            tabBarViewController?.select(type: .discover)
        }

        #if targetEnvironment(UIKitForMac)
        let helper = WindowToolbarHelper()
        helper.applyStyle(toWindow: window.windowScene!)
        #endif


        window.tintColor = Color.main
        window.makeKeyAndVisible()
    }

    func logout() {
        tabBarViewController?.reload()
        Item.deleteAllCached()
        userSettings.logout()
    }

    func handleDeeplink(url: URL) {
        showLogin()
        let token = url.absoluteString.replacingOccurrences(of: "icro://", with: "")
        loginViewController.verify(token: token)
    }
}
