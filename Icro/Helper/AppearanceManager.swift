//
//  Created by martin on 24.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

final class AppearanceManager {
    func applyAppearance() {
        UITabBar.appearance().barTintColor = Theme.colorTheme.backgroundColor
        UINavigationBar.appearance().barTintColor = Theme.colorTheme.backgroundColor
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: Color.textColor
        ]
        UITableView.appearance().backgroundColor = Theme.colorTheme.backgroundColor
    }
}
