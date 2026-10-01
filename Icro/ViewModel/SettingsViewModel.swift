//
//  Created by martin on 21.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    init(canSendMail: Bool) {
        self.canSendMail = canSendMail
    }

    let canSendMail: Bool

    let title = NSLocalizedString("SETTINGSVIEWCONTROLLER_TITLE", comment: "")
}
