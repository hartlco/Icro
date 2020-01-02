//
//  Created by martin on 21.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit
import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    enum CustomBlogType {
        case wordpress
        case micropub
        case none
    }

    var objectWillChange = ObservableObjectPublisher()

    private let userSettings: UserSettings
    private let notificationCenter: NotificationCenter

    init(userSettings: UserSettings,
         notificationCenter: NotificationCenter = .default) {
        self.userSettings = userSettings
        self.isWordpressBlog = userSettings.wordpressInfo != nil
        self.wordpressURL = userSettings.wordpressInfo?.urlString ?? ""
        self.wordpressUsername = userSettings.wordpressInfo?.username ?? ""
        self.wordpressPassword = userSettings.wordpressInfo?.password ?? ""
        self.isMicropubBlog = userSettings.micropubInfo != nil
        self.micropubURL = userSettings.micropubInfo?.urlString ?? ""
        self.micropubToken = userSettings.micropubInfo?.micropubToken ?? ""
        self.notificationCenter = notificationCenter
        self.indieAuthMeURLString = userSettings.indieAuthMeURLString

        if isWordpressBlog {
            isMicropubBlog = false
        } else if isMicropubBlog {
            isWordpressBlog = false
        }

        notificationCenter.addObserver(self, selector: #selector(updateValues), name: .micropubAccessTokenChanged, object: nil)
    }
    @objc private func updateValues() {
        self.micropubToken = userSettings.micropubToken ?? ""

        objectWillChange.send()
    }

    var isWordpressBlog: Bool {
        didSet {
            if isWordpressBlog, isMicropubBlog {
                isMicropubBlog = false
            }
            updateSetup()
        }
    }

    var wordpressURL: String {
        didSet {
            updateSetup()
        }
    }

    var wordpressUsername: String {
        didSet {
            updateSetup()
        }
    }

    var wordpressPassword: String {
        didSet {
            updateSetup()
        }
    }

    var isMicropubBlog: Bool {
        didSet {
            if isWordpressBlog, isMicropubBlog {
                isWordpressBlog = false
            }
            updateSetup()
        }
    }

    var micropubURL: String {
        didSet {
            updateSetup()
        }
    }

    var micropubToken: String {
        didSet {
            updateSetup()
        }
    }

    var indieAuthMeURLString: String {
        didSet {
            updateSetup()
        }
    }

    let title = NSLocalizedString("SETTINGSVIEWCONTROLLER_TITLE", comment: "")
    let appearanceTitle = NSLocalizedString( "SETTINGSVIEWCONTROLLER_APPEARANCE_TITLE", comment: "")
    let appearanceButtonText = NSLocalizedString("SETTINGSVIEWCONTROLLER_THEME_TITLE", comment: "")

    let wordpressTitle = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGSETUP_TITLE", comment: "")
    let wordpressSubTitle = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGINFO_TEXT", comment: "")
    let wordpressSwitchTitle = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGSETUPSWITCH_TEXT", comment: "")

    private func updateSetup() {
        objectWillChange.send()

        if isWordpressBlog,
            !wordpressURL.isEmpty,
            !wordpressUsername.isEmpty,
            !wordpressPassword.isEmpty {
            let wordpressInfo = UserSettings.WordpressInfo(urlString: wordpressURL,
                                                           username: wordpressUsername,
                                                           password: wordpressPassword)
            userSettings.setWordpressInfo(info: wordpressInfo)
        } else {
            userSettings.setWordpressInfo(info: nil)
        }

        if isMicropubBlog,
            !micropubURL.isEmpty,
            !micropubToken.isEmpty {
            let micropubInfo = UserSettings.MicropubInfo(urlString: micropubURL,
                                                         micropubToken: micropubToken)
            userSettings.setMicropubInfo(info: micropubInfo)
        } else {
            userSettings.setMicropubInfo(info: nil)
        }

        userSettings.indieAuthMeURLString = indieAuthMeURLString
    }
}
