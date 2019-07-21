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
    private let presentedController: UIViewController
    private let appNavigator: AppNavigator
    private let userSettings: UserSettings

    init(presentedController: UIViewController,
         appNavigator: AppNavigator,
         userSettings: UserSettings = .shared) {
        self.presentedController = presentedController
        self.appNavigator = appNavigator
        self.userSettings = userSettings
    }

    var muteView: MuteView {
        let viewModel = MuteViewModel(userSettings: userSettings)
        return MuteView(viewModel: viewModel)
    }

    var acknowledgmentsView: AcknowledgementView {
        return AcknowledgementView()
    }

    func openSupportMail() {
        guard MFMailComposeViewController.canSendMail() else { return }

        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = self
        viewController.setToRecipients(["icro@hartl.co"])
        viewController.setSubject("Icro support")
        presentedController.present(viewController, animated: true, completion: nil)
    }

    func logout() {
        presentedController.dismiss(animated: true, completion: nil)
        appNavigator.logout()
    }
}

extension SettingsNavigator: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
