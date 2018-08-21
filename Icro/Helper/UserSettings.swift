//
//  Created by martin on 01.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import KeychainAccess

extension Notification.Name {
    static let blackListChanged = Notification.Name(rawValue: "blackListChanged")
}

final class UserSettings {
    struct WordpressInfo {
        let urlString: String
        let username: String
        let password: String
    }

    struct MicropubInfo {
        let urlString: String
        let micropubToken: String
    }

    static let shared = UserSettings()

    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private let keychain = Keychain(service: "co.hartl.icro")

    init(userDefaults: UserDefaults = .standard,
         notificationCenter: NotificationCenter = .default) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
    }

    // swiftlint:disable identifier_name
    var lastread_timeline: String? {
        set {
            userDefaults.set(newValue, forKey: #function)
            userDefaults.synchronize()
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? String else { return "" }
            return data
        }
    }

    var username: String {
        set {
            userDefaults.set(newValue, forKey: #function)
            userDefaults.synchronize()
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? String else { return "" }
            return data
        }
    }

    var token: String {
        set {
            userDefaults.set(newValue, forKey: #function)
            userDefaults.synchronize()
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? String else { return "" }
            return data
        }
    }

    var defaultSite: String {
        set {
            userDefaults.set(newValue, forKey: #function)
            userDefaults.synchronize()
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? String else { return "micro.blog" }
            return data
        }
    }

    var wordPressUsername: String? {
        set {
            keychain[#function] = newValue
        }
        get {
            return keychain[#function]
        }
    }

    var wordPressUrlString: String? {
        set {
            keychain[#function] = newValue
        }
        get {
            return keychain[#function]
        }
    }

    var wordPressPassword: String? {
        set {
            keychain[#function] = newValue
        }
        get {
            return keychain[#function]
        }
    }

    var wordpressInfo: WordpressInfo? {
        guard let username = wordPressUsername,
        let urlString = wordPressUrlString,
            let password = wordPressPassword else { return nil }

        return WordpressInfo(urlString: urlString, username: username, password: password)
    }

    func setWordpressInfo(info: WordpressInfo?) {
        guard let info = info else {
            wordPressPassword = nil
            wordPressUrlString = nil
            wordPressUsername = nil
            return
        }

        wordPressPassword = info.password
        wordPressUrlString = info.urlString
        wordPressUsername = info.username
    }

    var micropubUrlString: String? {
        set {
            keychain[#function] = newValue
        }
        get {
            return keychain[#function]
        }
    }

    var micropubToken: String? {
        set {
            keychain[#function] = newValue
        }
        get {
            return keychain[#function]
        }
    }

    var micropubInfo: MicropubInfo? {
        guard let urlString = micropubUrlString,
            let token = micropubToken else { return nil }

        return MicropubInfo(urlString: urlString, micropubToken: token)
    }

    func setMicropubInfo(info: MicropubInfo?) {
        guard let info = info else {
            micropubUrlString = nil
            micropubToken = nil
            return
        }

        micropubToken = info.micropubToken
        micropubUrlString = info.urlString
    }

    var loggedIn: Bool {
        return username != "" && token != ""
    }

    func save(loginInformation: LoginInformation) {
        username = loginInformation.username
        token = loginInformation.token
        defaultSite = loginInformation.defaultSite
    }

    func addToBlacklist(word: String?) {
        guard let word = word else { return }

        var words = Set(blacklist)
        words.insert(word)
        let array = Array(words).sorted()
        blacklist = array
    }

    func removeIndexFromBlacklist(index: Int) {
        guard index < blacklist.count else { return }

        let delete = blacklist[index]
        var words = Set(blacklist)
        words.remove(delete)
        let array = Array(words).sorted()
        blacklist = array
    }

    var blacklist: [String] {
        set {
            if newValue != blacklist {
                userDefaults.set(newValue, forKey: #function)
                userDefaults.synchronize()
                notificationCenter.post(name: .blackListChanged, object: nil)
            }
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? [String] else { return [] }
            return data
        }
    }
}
