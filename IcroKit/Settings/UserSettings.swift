//
//  Created by martin on 01.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import KeychainAccess

public extension Notification.Name {
    public static let blackListChanged = Notification.Name(rawValue: "blackListChanged")
}

public final class UserSettings {
    public struct WordpressInfo {
        public init(urlString: String,
                    username: String,
                    password: String) {
            self.urlString = urlString
            self.username = username
            self.password = password
        }

        public let urlString: String
        public let username: String
        public let password: String
    }

    public struct MicropubInfo {
        public init(urlString: String,
                    micropubToken: String) {
            self.urlString = urlString
            self.micropubToken = micropubToken
        }

        public let urlString: String
        public let micropubToken: String
    }

    public static let shared = UserSettings()

    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter
    private let keychain = Keychain(service: "co.hartl.icro")

    public init(userDefaults: UserDefaults = UserDefaults(suiteName: "group.hartl.co.icro")!,
                notificationCenter: NotificationCenter = .default) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
    }

    // swiftlint:disable identifier_name
    public var lastread_timeline: String? {
        set {
            userDefaults.set(newValue, forKey: #function)
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? String else { return "" }
            return data
        }
    }

    public var username: String {
        set {
            userDefaults.set(newValue, forKey: #function)
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? String else { return "" }
            return data
        }
    }

    public var token: String {
        set {
            userDefaults.set(newValue, forKey: #function)
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? String else { return "" }
            return data
        }
    }

    public var defaultSite: String {
        set {
            userDefaults.set(newValue, forKey: #function)
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? String else { return "micro.blog" }
            return data
        }
    }

    public var wordPressUsername: String? {
        set {
            keychain[#function] = newValue
        }
        get {
            return keychain[#function]
        }
    }

    public var wordPressUrlString: String? {
        set {
            keychain[#function] = newValue
        }
        get {
            return keychain[#function]
        }
    }

    public var wordPressPassword: String? {
        set {
            keychain[#function] = newValue
        }
        get {
            return keychain[#function]
        }
    }

    public var wordpressInfo: WordpressInfo? {
        guard let username = wordPressUsername,
        let urlString = wordPressUrlString,
            let password = wordPressPassword else { return nil }

        return WordpressInfo(urlString: urlString, username: username, password: password)
    }

    public func setWordpressInfo(info: WordpressInfo?) {
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

    public var micropubUrlString: String? {
        set {
            keychain[#function] = newValue
        }
        get {
            return keychain[#function]
        }
    }

    public var micropubToken: String? {
        set {
            keychain[#function] = newValue
        }
        get {
            return keychain[#function]
        }
    }

    public var micropubInfo: MicropubInfo? {
        guard let urlString = micropubUrlString,
            let token = micropubToken else { return nil }

        return MicropubInfo(urlString: urlString, micropubToken: token)
    }

    public func setMicropubInfo(info: MicropubInfo?) {
        guard let info = info else {
            micropubUrlString = nil
            micropubToken = nil
            return
        }

        micropubToken = info.micropubToken
        micropubUrlString = info.urlString
    }

    public var loggedIn: Bool {
        return username != "" && token != ""
    }

    public func save(loginInformation: LoginInformation) {
        username = loginInformation.username
        token = loginInformation.token
        defaultSite = loginInformation.defaultSite
    }

    public func addToBlacklist(word: String?) {
        guard let word = word else { return }

        var words = Set(blacklist)
        words.insert(word)
        let array = Array(words).sorted()
        blacklist = array
    }

    public func removeIndexFromBlacklist(index: Int) {
        guard index < blacklist.count else { return }

        let delete = blacklist[index]
        var words = Set(blacklist)
        words.remove(delete)
        let array = Array(words).sorted()
        blacklist = array
    }

    public var blacklist: [String] {
        set {
            if newValue != blacklist {
                userDefaults.set(newValue, forKey: #function)
                notificationCenter.post(name: .blackListChanged, object: nil)
            }
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? [String] else { return [] }
            return data
        }
    }

    public var theme: Theme {
        set {
            userDefaults.set(newValue.rawValue, forKey: #function)
        }
        get {
            guard let themeString = userDefaults.string(forKey: #function),
                let theme = Theme(rawValue: themeString) else { return .light }
            return theme
        }
    }
}
