//
//  Created by martin on 21.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit
import SwiftUI
import Combine
import Settings

final class SettingsViewModel: ObservableObject {
    enum CustomBlogType {
        case wordpress
        case micropub
        case none
    }

    private let userSettings: UserSettings
    private let notificationCenter: NotificationCenter

    init(userSettings: UserSettings,
         notificationCenter: NotificationCenter = .default,
         canSendMail: Bool) {
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
        self.canSendMail = canSendMail
        self.useMediumContentFont = userSettings.useMediumContentFont

        if isWordpressBlog {
            isMicropubBlog = false
        } else if isMicropubBlog {
            isWordpressBlog = false
        }

        notificationCenter.addObserver(self, selector: #selector(updateValues), name: .micropubAccessTokenChanged, object: nil)
    }

    @objc private func updateValues() {
        self.micropubToken = userSettings.micropubToken ?? ""
    }

    let canSendMail: Bool

    @Published var isWordpressBlog: Bool {
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

    @Published var isMicropubBlog: Bool {
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

    @Published var micropubToken: String {
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

    // MARK: - Appearance

    var useMediumContentFont: Bool {
        didSet {
            updateSetup()
        }
    }

    private func updateSetup() {
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

        if isMicropubBlog {
            let micropubInfo = UserSettings.MicropubInfo(urlString: micropubURL,
                                                         micropubToken: micropubToken)
            userSettings.setMicropubInfo(info: micropubInfo)
        } else {
            userSettings.setMicropubInfo(info: nil)
        }

        userSettings.indieAuthMeURLString = indieAuthMeURLString
        userSettings.useMediumContentFont = useMediumContentFont
    }
}
