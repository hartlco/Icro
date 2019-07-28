//
//  Created by Martin Hartl on 12.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var navigator: AppNavigator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        navigator = AppNavigator(window: window!, userSettings: UserSettings.shared)

        if let firstUserActivity = connectionOptions.userActivities.first,
            firstUserActivity.activityType == UserActivities.compose.rawValue {
            navigator?.setupComposeWinodw()
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
