//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import AppDelegateComponent

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppDelegateComponentStore {
    let storedComponents: [AppDelegateComponent] = [DiscoveryCategoryComponent(),
                                                    UserDefaultsMigrationComponent()]
    private let componentRunner = AppDelegateComponentRunner()
    private let mainMenuBuilder = MainMenuBuilder()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return componentRunner.componentStore(self,
                                       application: application,
                                       didFinishLaunchingWithOptions: launchOptions)
    }

    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        componentRunner.componentStore(self,
                                       app: application,
                                       performFetchWithCompletionHandler: completionHandler)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return componentRunner.componentStore(self,
                                              app: app, open: url)
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

// MARK: - Main Menu

extension AppDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        mainMenuBuilder.buildMenu(with: builder)
    }

    @objc func handleMainMenuRefreshCommand(command: UIKeyCommand) {
        MainMenuActionNotifier().handleMainMenuCommand(command: command)
    }

    @objc func handleMainMenuComposeCommand(command: UIKeyCommand) {
        MainMenuActionNotifier().handleMainMenuCommand(command: command)
    }

    @objc func handleMainMenuSettingsCommand(command: UIKeyCommand) {
        MainMenuActionNotifier().handleMainMenuCommand(command: command)
    }

    @objc func handleMainMenuTimelineCommand(command: UIKeyCommand) {
        MainMenuActionNotifier().handleMainMenuCommand(command: command)
    }

    @objc func handleMainMenuMentionsCommand(command: UIKeyCommand) {
        MainMenuActionNotifier().handleMainMenuCommand(command: command)
    }

    @objc func handleMainMenuFavoritesCommand(command: UIKeyCommand) {
        MainMenuActionNotifier().handleMainMenuCommand(command: command)
    }

    @objc func handleMainMenuDiscoverCommand(command: UIKeyCommand) {
        MainMenuActionNotifier().handleMainMenuCommand(command: command)
    }

    @objc func handleMainMenuProfileCommand(command: UIKeyCommand) {
        MainMenuActionNotifier().handleMainMenuCommand(command: command)
    }

    @objc func handleMainMenuGoBackCommand(command: UIKeyCommand) {
        MainMenuActionNotifier().handleMainMenuCommand(command: command)
    }

    private func handleMainMenuCommand(command: UIKeyCommand) {
        MainMenuActionNotifier().handleMainMenuCommand(command: command)
    }

}
