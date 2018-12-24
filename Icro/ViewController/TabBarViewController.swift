//
//  Created by martin on 31.03.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit

class TabBarViewController: UITabBarController {
    private let userSettings: UserSettings
    private let appNavigator: AppNavigator
    fileprivate var previousViewController: UIViewController?

    init(userSettings: UserSettings,
         appNavigator: AppNavigator) {
        self.userSettings = userSettings
        self.appNavigator = appNavigator
        super.init(nibName: "TabBarViewController2", bundle: nil)
        commonInit()
        view.tintColor = Color.main
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        let types = [ListViewModel.ListType.timeline,
                               ListViewModel.ListType.mentions,
                               ListViewModel.ListType.favorites,
                               ListViewModel.ListType.discover,
                               ListViewModel.ListType.username(username: userSettings.username)
        ]

        let viewControllers: [UINavigationController] = types.map { type in
            let viewModel = ListViewModel(type: type)
            let navigationController = UINavigationController()
            navigationController.navigationBar.isTranslucent = false
            let itemNavigator = ItemNavigator(navigationController: navigationController)
            let viewController = ListViewController(viewModel: viewModel, itemNavigator: itemNavigator)
            viewController.view.tintColor = Color.main
            navigationController.viewControllers = [viewController]

            navigationController.tabBarItem = UITabBarItem(title: type.tabTitle, image: type.image, selectedImage: nil)

            let image = UIImage(named: "new")
            let newPostIcon = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showComposeViewController))
			newPostIcon.accessibilityLabel = "Compose"
            viewController.navigationItem.rightBarButtonItem = newPostIcon

            switch type {
            case .username:
                let settingsImage = UIImage(named: "settings")
                let settingsButton = UIBarButtonItem(image: settingsImage,
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(showSettingsViewController))
				settingsButton.accessibilityLabel = "Settings"
				viewController.navigationItem.leftBarButtonItem = settingsButton
            case .timeline:
                let photosButton  = UIBarButtonItem(title:
                    NSLocalizedString("TABBARVIEWCONTROLLER_PHOTOSBUTTON_TITLE", comment: ""),
                                                    style: .plain, target: self, action: #selector(showPhotosTimeline))
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

    // MARK: - Private

    @objc private func showComposeViewController() {
        let navController = UINavigationController()
        let viewModel = ComposeViewModel(mode: .post)
        let itemNavigator = ItemNavigator(navigationController: navController)
        let navigator = ComposeNavigator(navigationController: navController, viewModel: viewModel)
        let viewController = ComposeViewController(viewModel: viewModel, composeNavigator: navigator, itemNavigator: itemNavigator)
        navController.viewControllers = [viewController]
        present(navController, animated: true, completion: nil)
    }

    @objc private func showSettingsViewController() {
        let navigationController = UINavigationController()
        let mainNavigator = MainNavigator(navigationController: navigationController)
        let settingsNavigator = SettingsNavigator(navigationController: navigationController, appNavigator: appNavigator)
        let viewController = SettingsViewController(navigator: settingsNavigator,
                                                    mainNavigator: mainNavigator,
                                                    viewModel: SettingsViewModel(userSettings: userSettings))
        navigationController.viewControllers = [viewController]
        present(navigationController, animated: true, completion: nil)
    }

    @objc private func showPhotosTimeline() {
        guard let navigationController = selectedViewController as? UINavigationController else { return }

        let viewModel = ListViewModel(type: .photos)
        let itemNavigator = ItemNavigator(navigationController: navigationController)
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
