//
//  Created by martin on 24.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit

final class AppearanceManager {
    static let shared = AppearanceManager()

    private let notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }

    func applyAppearance() {
        UITabBar.appearance().barTintColor = Color.backgroundColor
        UINavigationBar.appearance().barTintColor = Color.backgroundColor
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: Color.textColor
        ]

        let listTableViewAppearance = UITableView.appearance(whenContainedInInstancesOf: [ListViewController.self])
        listTableViewAppearance.backgroundColor = Color.backgroundColor
        listTableViewAppearance.sectionIndexBackgroundColor = .green
        listTableViewAppearance.separatorColor = Color.separatorColor
    }
}
