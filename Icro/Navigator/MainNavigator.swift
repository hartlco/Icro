//
//  Created by martin on 15.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import SafariServices

final class MainNavigator {
    private let navigationController: UINavigationController
    private let userSettings: UserSettings

    init(navigationController: UINavigationController,
         userSettings: UserSettings = .shared) {
        self.navigationController = navigationController
        self.userSettings = userSettings
    }

    func openMicroBlog() {
        guard let url = URL(string: "https://micro.blog") else { return }
        let safariViewController = SFSafariViewController(url: url)
        navigationController.present(safariViewController, animated: true, completion: nil)
    }

    func openCommunityGuidlines() {
        guard let url = URL(string: "http://help.micro.blog/2017/community-guidelines/") else { return }

        let itemNavigator = ItemNavigator(navigationController: navigationController)
        itemNavigator.open(url: url)
    }
}
