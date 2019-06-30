//
//  Created by martin on 24.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit

extension Notification.Name {
    static let appearanceDidChange
        = NSNotification.Name("AppearanceDidChange")
}

final class AppearanceManager {
    static let shared = AppearanceManager()

    private let notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }

    func applyAppearance() {
        UITabBar.appearance().barTintColor = Theme.colorTheme.backgroundColor
        UINavigationBar.appearance().barTintColor = Theme.colorTheme.backgroundColor
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: Color.textColor
        ]

        let listTableViewAppearance = UITableView.appearance(whenContainedInInstancesOf: [ListViewController.self])
        listTableViewAppearance.backgroundColor = Theme.colorTheme.backgroundColor
        listTableViewAppearance.sectionIndexBackgroundColor = .green
        listTableViewAppearance.separatorColor = Theme.colorTheme.separatorColor

        let userListTableViewAppearance = UITableView.appearance(whenContainedInInstancesOf: [UserListViewController.self])

        userListTableViewAppearance.backgroundColor = Theme.colorTheme.backgroundColor
        userListTableViewAppearance.sectionIndexBackgroundColor = .green
        userListTableViewAppearance.separatorColor = Theme.colorTheme.separatorColor

        UITextView.appearance().backgroundColor = Theme.colorTheme.backgroundColor
        UITextView.appearance().textColor = Theme.colorTheme.textColor
        UIScrollView.appearance(whenContainedInInstancesOf: [ComposeViewController.self]).backgroundColor = Theme.colorTheme.backgroundColor

        switch Theme.currentTheme {
        case .light:
            UINavigationBar.appearance().barStyle = .default
        case .gray, .black:
            UINavigationBar.appearance().barStyle = .black
        }

        notificationCenter.post(name: .appearanceDidChange, object: nil)
    }

    func switchTheme(to newTheme: Theme) {
        Theme.currentTheme = newTheme
        UserSettings.shared.theme = newTheme
        applyAppearance()
    }
}
