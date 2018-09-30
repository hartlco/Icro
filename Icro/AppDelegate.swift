//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var navigator: AppNavigator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = ImageDownloadManager.shared

        application.setMinimumBackgroundFetchInterval(1800)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.tintColor = Color.main

        if let window = window {
            navigator = AppNavigator(window: window, userSettings: UserSettings.shared)
            navigator?.setup()
        }

        return true
    }

    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let viewModel = ListViewModel(type: .timeline)
        viewModel.load()
        viewModel.didFinishLoading = { cached in
            guard !cached else { return }
            completionHandler(.newData)
        }

        viewModel.didFinishWithError = { _ in
            completionHandler(.failed)
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        navigator?.handleDeeplink(url: url)
        return true
    }
}
