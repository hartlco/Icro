//
//  Created by martin on 21.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import AcknowList
import MessageUI
import IcroKit

final class SettingsNavigator: NSObject {
    private let navigationController: UINavigationController
    private let appNavigator: AppNavigator

    init(navigationController: UINavigationController,
         appNavigator: AppNavigator) {
        self.navigationController = navigationController
        self.appNavigator = appNavigator
    }

    func openAcknowledgements() {
        let viewController = AcknowListViewController()
        viewController.view.backgroundColor = Color.accentSuperLight
        navigationController.pushViewController(viewController, animated: true)
    }

    func openHartlCoOnMicroBlog() {
        let viewModel = ListViewModel(type: .username(username: "hartlco"))
        let itemNavigator = ItemNavigator(navigationController: navigationController)
        let viewController = ListViewController(viewModel: viewModel, itemNavigator: itemNavigator)
        navigationController.pushViewController(viewController, animated: true)
    }

    func openSupportMail() {
        guard MFMailComposeViewController.canSendMail() else { return }

        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = self
        viewController.setToRecipients(["icro@hartl.co"])
        viewController.setSubject("Icro support")
        navigationController.present(viewController, animated: true, completion: nil)
    }

    func openMicroBlog() {
        let mainNavigator = MainNavigator(navigationController: navigationController)
        mainNavigator.openMicroBlog()
    }

    func openBlacklist() {
        let viewModel = BlacklistViewModel(userSettings: UserSettings.shared)
        let mainNavigator = MainNavigator(navigationController: navigationController)
        let viewController = BlacklistViewController(viewModel: viewModel,
                                                     mainNavigator: mainNavigator)
        navigationController.pushViewController(viewController, animated: true)
    }

    func logout() {
        appNavigator.logout()
    }
}

extension SettingsNavigator: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
