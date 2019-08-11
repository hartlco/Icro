//
//  Created by martin on 11.08.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit

extension UIKeyCommand {
    var mainMenuKeyCommand: MainMenuKeyCommand? {
        return MainMenuKeyCommand.allCases.first { command in
            input == command.configuration.input &&
                modifierFlags == command.configuration.modifierFlags
        }
    }
}

enum MainMenuKeyCommand: CaseIterable {
    case refresh
    case compose
    case settings
    case timeline
    case mentions
    case favorites
    case discover
    case profile

    var command: UIKeyCommand {
        let config = configuration
        let command = UIKeyCommand(input: config.input,
                            modifierFlags: config.modifierFlags,
                            action: config.selector)
        command.title = config.title
        return command
    }

    // swiftlint:disable large_tuple
    var configuration: (input: String, modifierFlags: UIKeyModifierFlags, title: String, selector: Selector) {
        switch self {
        case .refresh:
            return ("R", [.command], "Refresh", #selector(AppDelegate.handleMainMenuRefreshCommand(command:)))
        case .compose:
            return ("N", [.command], "New Post", #selector(AppDelegate.handleMainMenuComposeCommand(command:)))
        case .settings:
            return (",", [.command], "Settings", #selector(AppDelegate.handleMainMenuSettingsCommand(command:)))
        case .timeline:
            return ("1", [.command], "Timeline", #selector(AppDelegate.handleMainMenuTimelineCommand(command:)))
        case .mentions:
            return ("2", [.command], "Mentions", #selector(AppDelegate.handleMainMenuMentionsCommand(command:)))
        case .favorites:
            return ("3", [.command], "Favorites", #selector(AppDelegate.handleMainMenuFavoritesCommand(command:)))
        case .discover:
            return ("4", [.command], "Discover", #selector(AppDelegate.handleMainMenuDiscoverCommand(command:)))
        case .profile:
            return ("5", [.command], "Profile", #selector(AppDelegate.handleMainMenuProfileCommand(command:)))
        }
    }

    var notificationName: Notification.Name {
        switch self {
        case .refresh:
            return .mainMenuRefresh
        case .compose:
            return .mainMenuCompose
        case .settings:
            return .mainMenuSettings
        case .timeline, .mentions, .favorites, .discover, .profile:
            return .mainMenuTabChange
        }
    }
}

extension Notification.Name {
    static let mainMenuRefresh = Notification.Name("mainMenuRefresh")
    static let mainMenuCompose = Notification.Name("mainMenuCompose")
    static let mainMenuSettings = Notification.Name("mainMenuSettings")
    static let mainMenuTabChange = Notification.Name("mainMenuTabChange")
}

final class MainMenuActionNotifier {
    private let notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }

    func handleMainMenuCommand(command: UIKeyCommand) {
        guard let name = command.mainMenuKeyCommand?.notificationName else {
            return
        }

        notificationCenter.post(name: name, object: command)
    }
}
