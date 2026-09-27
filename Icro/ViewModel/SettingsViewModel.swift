//
//  Created by martin on 21.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Settings

final class SettingsViewModel: ObservableObject {
    private let userSettings: UserSettings

    init(userSettings: UserSettings,
         canSendMail: Bool) {
        self.userSettings = userSettings
        self.canSendMail = canSendMail
        self.useMediumContentFont = userSettings.useMediumContentFont
    }

    let canSendMail: Bool

    let title = NSLocalizedString("SETTINGSVIEWCONTROLLER_TITLE", comment: "")
    let appearanceTitle = NSLocalizedString( "SETTINGSVIEWCONTROLLER_APPEARANCE_TITLE", comment: "")
    let appearanceButtonText = NSLocalizedString("SETTINGSVIEWCONTROLLER_THEME_TITLE", comment: "")

    // MARK: - Appearance

    var useMediumContentFont: Bool {
        didSet {
            updateSetup()
        }
    }

    private func updateSetup() {
        userSettings.useMediumContentFont = useMediumContentFont
    }
}
