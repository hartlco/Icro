//
//  Created by martin on 21.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import AcknowList
import MessageUI
import IcroKit
import SwiftUI

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
        let itemNavigator = ItemNavigator(navigationController: navigationController, appNavigator: appNavigator)
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
        let viewModel = MuteViewModel(userSettings: UserSettings.shared)
        let muteView = MuteView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: muteView)
        navigationController.pushViewController(viewController, animated: true)
    }

    func openThemeSelector(sourceView: UIView, completion: @escaping (Theme) -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for theme in Theme.allCases {
            let action = UIAlertAction(title: NSLocalizedString(theme.rawValue, comment: ""),
            style: .default) { _ in
                completion(theme)
            }

            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title:
            NSLocalizedString("ITEMNAVIGATOR_MOREALERT_CANCELACTION", comment: ""),
                                                style: .cancel,
                                                handler: nil))

        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect = sourceView.bounds

        navigationController.present(alertController, animated: true, completion: nil)
    }

    func logout() {
        navigationController.dismiss(animated: true, completion: nil)
        appNavigator.logout()
    }
}

extension SettingsNavigator: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
