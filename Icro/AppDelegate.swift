//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import AppDelegateComponent

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppDelegateComponentStore {
    let storedComponents: [AppDelegateComponent] = [DiscoveryCategoryComponent(),
                                                    UserDefaultsMigrationComponent(),
                                                    BackgroundFetchComponent()]
    private let componentRunner = AppDelegateComponentRunner()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
