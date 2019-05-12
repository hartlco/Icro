//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import AppDelegateComponent

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppDelegateComponentStore {
    let storedComponents: [AppDelegateComponent] = [NavigatorComponent(),
                                                    DiscoveryCategoryComponent(),
                                                    UserDefaultsMigrationComponent()]
    private let componentRunner = AppDelegateComponentRunner()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.setMinimumBackgroundFetchInterval(1800)

        componentRunner.componentStore(self,
                                       application: application,
                                       didFinishLaunchingWithOptions: launchOptions)

        AppearanceManager().applyAppearance()

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
        return componentRunner.componentStore(self,
                                              app: app, open: url)
    }
}
