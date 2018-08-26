//
//  Created by martin on 19.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

final class AppNavigator {
    private let window: UIWindow
    private let userSettings: UserSettings
    private let loginViewController: LoginViewController
    private let loginViewModel = LoginViewModel()

    init(window: UIWindow,
         userSettings: UserSettings) {
        self.window = window
        self.userSettings = userSettings

        self.loginViewController = LoginViewController(viewModel: loginViewModel)

        loginViewModel.didLogin = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.setup()
        }
    }

    func setup() {
        if userSettings.loggedIn {
            window.rootViewController = TabBarViewController(userSettings: userSettings, appNavigator: self)
        } else {
            window.rootViewController = UINavigationController(rootViewController: loginViewController)
        }

        window.makeKeyAndVisible()
    }

    func logout() {
        Item.deleteAllCached()
        userSettings.token = ""
        userSettings.username = ""
        userSettings.lastread_timeline = nil
        userSettings.setWordpressInfo(info: nil)
        userSettings.setMicropubInfo(info: nil)
        window.rootViewController = UINavigationController(rootViewController: loginViewController)
    }

    func handleDeeplink(url: URL) {
        guard let navigation = window.rootViewController as? UINavigationController,
            navigation.viewControllers.first == loginViewController else { return }

        let token = url.absoluteString.replacingOccurrences(of: "icro://", with: "")
        loginViewController.verify(token: token)
    }
}
