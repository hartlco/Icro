//
//  Created by martin on 30.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit
import Combine
import SwiftUI

final class MuteViewModel: BindableObject {
    var didChange = PassthroughSubject<Void, Never>()

    private let userSettings: UserSettings

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }

    var words: [String] {
        return userSettings.blacklist
    }

    func add(word: String?) {
        userSettings.addToBlacklist(word: word)
        didChange.send()
    }

    func remove(at index: Int) {
        userSettings.removeIndexFromBlacklist(index: index)
        didChange.send()
    }

    var title: String {
        return NSLocalizedString("BLACKLISTVIEWMODEL_TITLE", comment: "")
    }
}
