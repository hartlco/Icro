//
//  Created by martin on 15.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import SafariServices

final class MainNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func openMicroBlog() {
        guard let url = URL(string: "https://micro.blog") else { return }
        let safariViewController = SFSafariViewController(url: url)
        navigationController.present(safariViewController, animated: true, completion: nil)
    }

    func openCommunityGuidlines() {
        guard let url = URL(string: "http://help.micro.blog/2017/community-guidelines/") else { return }

        let safariViewController = SFSafariViewController(url: url)
        navigationController.present(safariViewController, animated: true, completion: nil)
    }
}
