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
