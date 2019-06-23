//
//  Created by Martin Hartl on 22.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import IcroKit

final class SettingsViewNavigator {
    private let userSettings: UserSettings

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }

    var muteView: MuteView {
        let viewModel = MuteViewModel(userSettings: userSettings)
        return MuteView(viewModel: viewModel)
    }
}
