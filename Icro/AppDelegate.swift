//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import AppDelegateComponent

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppDelegateComponentStore {
    let storedComponents: [AppDelegateComponent] = [NavigatorComponent()]
    private let componentRunner = AppDelegateComponentRunner()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        migrateUserDefaultsToAppGroups()

        application.setMinimumBackgroundFetchInterval(1800)

        componentRunner.componentStore(self,
                                       application: application,
                                       didFinishLaunchingWithOptions: launchOptions)

        DiscoveryCategoryManager.shared.update()
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

func migrateUserDefaultsToAppGroups() {
    // User Defaults - Old
    let userDefaults = UserDefaults.standard

    // App Groups Default - New
    let groupDefaults = UserDefaults(suiteName: "group.hartl.co.icro")

    // Key to track if we migrated
    let didMigrateToAppGroups = "DidMigrateToAppGroups"

    if let groupDefaults = groupDefaults {
        if !groupDefaults.bool(forKey: didMigrateToAppGroups) {
            for key in userDefaults.dictionaryRepresentation().keys {
                groupDefaults.set(userDefaults.dictionaryRepresentation()[key], forKey: key)
            }
            groupDefaults.set(true, forKey: didMigrateToAppGroups)
            groupDefaults.synchronize()
            print("Successfully migrated defaults")
        } else {
            print("No need to migrate defaults")
        }
    } else {
        print("Unable to create NSUserDefaults with given app group")
    }

}
