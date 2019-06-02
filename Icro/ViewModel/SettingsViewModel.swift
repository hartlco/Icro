//
//  Created by martin on 21.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit

final class SettingsViewModel {
    let tipJarViewModel = TipJarViewModel()

    private let userSettings: UserSettings

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }

    let title = NSLocalizedString("SETTINGSVIEWCONTROLLER_TITLE", comment: "")
    let appearanceTitle = NSLocalizedString( "SETTINGSVIEWCONTROLLER_APPEARANCE_TITLE", comment: "")
    let appearanceButtonText = NSLocalizedString("SETTINGSVIEWCONTROLLER_THEME_TITLE", comment: "")

    var appearanceText: String {
        return NSLocalizedString(userSettings.theme.rawValue, comment: "")
    }

    let wordpressTitle = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGSETUP_TITLE", comment: "")
    let wordpressSubTitle = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGINFO_TEXT", comment: "")
    let wordpressSwitchTitle = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGSETUPSWITCH_TEXT", comment: "")

    var wordPressSetup: UserSettings.WordpressInfo? {
        get {
            return userSettings.wordpressInfo
        }

        set {
            userSettings.setWordpressInfo(info: newValue)
        }
    }

    var micropubSetup: UserSettings.MicropubInfo? {
        get {
            return userSettings.micropubInfo
        }

        set {
            userSettings.setMicropubInfo(info: newValue)
        }
    }
}
