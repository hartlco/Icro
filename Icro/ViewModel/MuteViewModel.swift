//
//  Created by martin on 30.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit
import Combine
import SwiftUI

final class MuteViewModel: ObservableObject {
    var objectWillChange = ObservableObjectPublisher()

    private let userSettings: UserSettings

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }

    var words: [String] {
        return userSettings.blacklist
    }

    func add(word: String?) {
        objectWillChange.send()
        userSettings.addToBlacklist(word: word)
    }

    func remove(at index: Int) {
        objectWillChange.send()
        userSettings.removeIndexFromBlacklist(index: index)
    }

    func remove(word: String) {
        objectWillChange.send()
        userSettings.removeWordFromBlacklist(word: word)
    }

    var title: String {
        return NSLocalizedString("BLACKLISTVIEWMODEL_TITLE", comment: "")
    }
}
