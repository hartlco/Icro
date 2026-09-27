//
//  Created by martin on 24.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import Style

final class AppearanceManager {
    static let shared = AppearanceManager()

    private let notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }

    func applyAppearance() {
        let listTableViewAppearance = UITableView.appearance(whenContainedInInstancesOf: [ListViewController.self])
        listTableViewAppearance.backgroundColor = Color.backgroundColor
        listTableViewAppearance.separatorColor = Color.separatorColor
    }
}
