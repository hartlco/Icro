//
//  Created by Martin Hartl on 12.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import Settings

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var navigator: AppNavigator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        navigator = AppNavigator(window: window!,
                                 userSettings: UserSettings.shared,
                                 notificationCenter: NotificationCenter.default,
                                 application: .shared)

        if let firstUserActivity = connectionOptions.userActivities.first {
            if firstUserActivity.activityType == UserActivities.compose.rawValue {
                navigator?.setupComposeWinodw()
            }
            if firstUserActivity.activityType == UserActivities.settings.rawValue {
                navigator?.setupSettingsWindow()
            }
        } else {
            navigator?.setup()
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach { [weak self] context in
            guard let self = self else { return }
            self.navigator?.handleDeeplink(url: context.url)
        }
    }
}
