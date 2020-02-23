//
//  Created by martin on 15.09.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import AppDelegateComponent
import Client

final class NotificationComponent: AppDelegateComponent {
    private let client: Client

    init(client: Client = URLSession.shared) {
        self.client = client
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.applicationIconBadgeNumber = 0
        registerForPushNotifications(application: application)
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        let pushRegistration = PushRegistration(token: token)
        client.load(resource: pushRegistration.register()) { _ in }
        print("Device Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }

    // MARK: - Notifications
    func registerForPushNotifications(application: UIApplication) {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }

        application.registerForRemoteNotifications()
    }
}
