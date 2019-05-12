//
//  Created by Martin Hartl on 12.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import AppDelegateComponent

final class UserDefaultsMigrationComponent: AppDelegateComponent {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {

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
}
