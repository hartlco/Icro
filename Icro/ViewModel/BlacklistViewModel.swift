//
//  Created by martin on 30.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

class BlacklistViewModel {
    private let userSettings: UserSettings

    var update: (() -> Void)?

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }

    var numberOfRows: Int {
        return userSettings.blacklist.count
    }

    func word(for row: Int) -> String {
        return userSettings.blacklist[row]
    }

    func add(word: String?) {
        userSettings.addToBlacklist(word: word)
        update?()
    }

    func remove(at indexPath: IndexPath) {
        userSettings.removeIndexFromBlacklist(index: indexPath.row)
        update?()
    }

    var title: String {
        return NSLocalizedString("BLACKLISTVIEWMODEL_TITLE", comment: "")
    }
}
