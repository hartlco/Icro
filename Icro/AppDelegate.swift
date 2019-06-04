//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import AppDelegateComponent

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppDelegateComponentStore {
    var window: UIWindow?
    let storedComponents: [AppDelegateComponent] = [NavigatorComponent(),
                                                    DiscoveryCategoryComponent(),
                                                    UserDefaultsMigrationComponent(),
                                                    BackgroundFetchComponent()]
    private let componentRunner = AppDelegateComponentRunner()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigator = AppNavigator(window: window!, userSettings: UserSettings.shared)
        navigator.setup()
//        let tabBarViewController = TabBarViewController(userSettings: UserSettings.shared, appNavigator: AppNavigator(window: window!, userSettings: UserSettings.shared))
//        window?.rootViewController = tabBarViewController
//
//        if !UserSettings.shared.loggedIn {
//            tabBarViewController.select(type: .discover)
//        }
//
//        window?.tintColor = Color.main
        window?.makeKeyAndVisible()
        return componentRunner.componentStore(self,
                                       application: application,
                                       didFinishLaunchingWithOptions: launchOptions)
    }

    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        componentRunner.componentStore(self,
                                       app: application,
                                       performFetchWithCompletionHandler: completionHandler)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return componentRunner.componentStore(self,
                                              app: app, open: url)
    }
}
