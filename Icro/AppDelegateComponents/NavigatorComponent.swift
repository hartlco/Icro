//
//  Created by Martin Hartl on 12.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import AppDelegateComponent
import IcroKit

final class NavigatorComponent: AppDelegateComponent {
    private let window: UIWindow
    private let navigator: AppNavigator

    init(window: UIWindow = UIWindow(frame: UIScreen.main.bounds),
         userSettings: UserSettings = .shared) {
        self.window = window
        self.navigator = AppNavigator(window: window, userSettings: UserSettings.shared)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        navigator.setup()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        navigator.handleDeeplink(url: url)
        return true
    }
}
