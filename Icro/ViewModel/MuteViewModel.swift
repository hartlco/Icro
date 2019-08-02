//
//  Created by martin on 30.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit
import Combine
import SwiftUI

final class MuteViewModel: ObservableObject {
    var willChange = PassthroughSubject<Void, Never>()

    private let userSettings: UserSettings

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }

    var words: [String] {
        return userSettings.blacklist
    }

    func add(word: String?) {
        willChange.send()
        userSettings.addToBlacklist(word: word)
    }

    func remove(at index: Int) {
        willChange.send()
        userSettings.removeIndexFromBlacklist(index: index)
    }

    var title: String {
        return NSLocalizedString("BLACKLISTVIEWMODEL_TITLE", comment: "")
    }
}
