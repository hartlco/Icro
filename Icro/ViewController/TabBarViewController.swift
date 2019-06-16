//
//  Created by martin on 31.03.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit
import SwiftUI
import TypedSymbols

class TabBarViewController: UITabBarController {
    private let userSettings: UserSettings
    private let appNavigator: AppNavigator
    private var types: [ListViewModel.ListType]
    fileprivate var previousViewController: UIViewController?

    var didSwitchToIndexByCommand: (Int) -> Void = { _ in }

    init(userSettings: UserSettings,
         appNavigator: AppNavigator) {
        self.userSettings = userSettings
        self.appNavigator = appNavigator
        self.types = [ListViewModel.ListType.timeline,
                 ListViewModel.ListType.mentions,
                 ListViewModel.ListType.favorites,
                 ListViewModel.ListType.discover,
                 ListViewModel.ListType.username(username: userSettings.username)
        ]

        super.init(nibName: "TabBarViewController", bundle: nil)
        commonInit()
        view.tintColor = Color.main
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select(type: ListViewModel.ListType) {
        guard let index = types.firstIndex(of: type) else { return }
        selectedIndex = index
    }

    private func commonInit() {
        let viewControllers: [UINavigationController] = types.map { type in
            let viewModel = ListViewModel(type: type)
            let navigationController = UINavigationController()
            navigationController.navigationBar.isTranslucent = false
            let itemNavigator = ItemNavigator(navigationController: navigationController, appNavigator: appNavigator)
            let viewController = ListViewController(viewModel: viewModel, itemNavigator: itemNavigator)
            viewController.view.tintColor = Color.main
            navigationController.viewControllers = [viewController]

            navigationController.tabBarItem = UITabBarItem(title: type.tabTitle, image: type.image, selectedImage: nil)

            let image = UIImage(symbol: .square_and_pencil)
            let newPostIcon = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showComposeViewController))
			newPostIcon.accessibilityLabel = "Compose"
            viewController.navigationItem.rightBarButtonItem = newPostIcon

            switch type {
            case .username:
                let settingsImage = UIImage(symbol: .gear)
                let settingsButton = UIBarButtonItem(image: settingsImage,
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(showSettingsViewController))
				settingsButton.accessibilityLabel = "Settings"
				viewController.navigationItem.leftBarButtonItem = settingsButton
            case .timeline:
                let photosButton  = UIBarButtonItem(image: UIImage(symbol: .photo),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(showPhotosTimeline))
                viewController.navigationItem.leftBarButtonItem = photosButton
            default:
                break
            }

            return navigationController
        }

        tabBar.isTranslucent = false

        setViewControllers(viewControllers, animated: false)
        previousViewController = viewControllers.first
    }

    func reload() {
        self.types = [ListViewModel.ListType.timeline,
                      ListViewModel.ListType.mentions,
                      ListViewModel.ListType.favorites,
                      ListViewModel.ListType.discover,
                      ListViewModel.ListType.username(username: userSettings.username)]
        commonInit()
    }

    // MARK: - Private

    @objc func showComposeViewController() {
        appNavigator.showComposeViewController()
    }

    @objc private func showSettingsViewController() {
        let navigationController = UINavigationController()
        let itemNavigator = ItemNavigator(navigationController: navigationController, appNavigator: appNavigator)
//        let settingsContentView = SettingsContentView(itemNavigator: itemNavigator,
//                                                      dismissAction: { [weak self] in
//                                                        guard let self = self else { return }
//                                                        self.presentedViewController?.dismiss(animated: true, completion: nil)
//        },
//                                                      store: SettingsStore())
//        present(UIHostingController(rootView: settingsContentView), animated: true, completion: nil)

        let settingsNavigator = SettingsNavigator(navigationController: navigationController, appNavigator: appNavigator)
        let viewModel = SettingsViewModel(userSettings: userSettings)
        let settingsViewCOntroller = SettingsViewController(navigator: settingsNavigator,
                                                            mainNavigator: MainNavigator(navigationController: navigationController),
                                                            viewModel: viewModel)
        navigationController.viewControllers = [settingsViewCOntroller]
        present(navigationController, animated: true, completion: nil)
    }

    @objc private func showPhotosTimeline() {
        guard let navigationController = selectedViewController as? UINavigationController else { return }

        let viewModel = ListViewModel(type: .photos)
        let itemNavigator = ItemNavigator(navigationController: navigationController, appNavigator: appNavigator)
        let viewController = ListViewController(viewModel: viewModel, itemNavigator: itemNavigator)
        navigationController.pushViewController(viewController, animated: true)
    }
}

protocol ScrollToTop {
    func scrollToTop()
}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if previousViewController == viewController,
        let navigation = viewController as? UINavigationController,
        let scrollToTop = navigation.viewControllers.first as? ScrollToTop {
            scrollToTop.scrollToTop()
        }
        previousViewController = viewController
    }
}

// MARK: - Keyboard shortcuts

extension TabBarViewController {
    override var keyCommands: [UIKeyCommand]? {
        let composeCommand = UIMutableKeyCommand(input: "n", modifierFlags: .command, action: #selector(showComposeViewController))
        composeCommand.title = "Compose"
        composeCommand.discoverabilityTitle = "Compose"

        let settingsCommand = UIMutableKeyCommand(input: ",", modifierFlags: .command, action: #selector(showSettingsViewController))
        settingsCommand.title = "Settings"
        settingsCommand.discoverabilityTitle = "Settings"

        return types.enumerated().map { index, type in
            return UIMutableKeyCommand(input: "\(index + 1)",
                modifierFlags: .command,
                action: #selector(selectType(sender:)),
                discoverabilityTitle: type.tabTitle ?? type.title)
        } + [composeCommand, settingsCommand]
    }

    @objc private func selectType(sender: UIKeyCommand) {
        guard let input = sender.input,
            let index = Int(input),
            index > 0,
            index < types.count + 1 else { return }
        selectedIndex = index - 1
        didSwitchToIndexByCommand(selectedIndex)
    }
}
