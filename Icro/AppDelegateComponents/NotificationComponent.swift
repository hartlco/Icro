//
//  Created by martin on 15.09.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import AppDelegateComponent

final class NotificationComponent: AppDelegateComponent {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }

    // MARK: - Notifications
    func registerForPushNotifications() {
      UNUserNotificationCenter.current() // 1
        .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
          granted, error in
          print("Permission granted: \(granted)") // 3
      }

        UIApplication.shared.registerForRemoteNotifications()
    }
}
