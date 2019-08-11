//
//  Created by martin on 11.08.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation

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
        }
    }
}

extension Notification.Name {
    static let mainMenuRefresh = Notification.Name("mainMenuRefresh")
    static let mainMenuCompose = Notification.Name("mainMenuCompose")
    static let mainMenuSettings = Notification.Name("mainMenuSettings")
}

final class MainMenuActionNotifier {
    func handleMainMenuCommand(command: UIKeyCommand) {
        guard let name = command.mainMenuKeyCommand?.notificationName else {
            return
        }

        NotificationCenter.default.post(name: name, object: command)
    }
}
