struct Settings {
    var text = "Hello, World!"
}

import Foundation

public extension Notification.Name {
    static let blackListChanged = Notification.Name(rawValue: "blackListChanged")
}

public final class UserSettings {
    public static let shared = UserSettings()

    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter

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

    public var preferredBlogDestination: String? {
        get { userDefaults.string(forKey: #function) }
        set { userDefaults.set(newValue, forKey: #function) }
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

    public func removeWordFromBlacklist(word: String) {
        guard let index = blacklist.firstIndex(of: word) else { return }
        removeIndexFromBlacklist(index: index)
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

    // MARK: - Appearance

    public var useMediumContentFont: Bool {
        set {
            userDefaults.set(newValue, forKey: #function)
        }
        get {
            guard let data = userDefaults.value(forKey: #function) as? Bool else { return false }
            return data
        }
    }

    public func logout() {
        token = ""
        username = ""
        lastread_timeline = nil
        preferredBlogDestination = nil
    }
}
