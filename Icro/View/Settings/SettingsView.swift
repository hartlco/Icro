//
//  Created by Martin Hartl on 02.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit

enum SettingsComponent {
    case header(title: String)
    case separator(insets: UIEdgeInsets)
    case cell(type: SettingsCellType)
    case footer(title: String)
}

enum SettingsCellType {
    case labelWithButton
    case labelWithSwitch
    case button
    case inputView
    case custom(view: UIView)
}

struct SettingsSection {
    let title: String?
    let subTitle: String?
    let cellTypes: [SettingsCellType]
}
