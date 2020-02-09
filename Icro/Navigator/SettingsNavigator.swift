//
//  Created by martin on 21.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import MessageUI
import IcroKit
import SwiftUI
import Settings

final class SettingsNavigator: NSObject {
    private let presentedController: UIViewController
    private let appNavigator: AppNavigator
    private let userSettings: UserSettings
    private let application: UIApplication

    init(presentedController: UIViewController,
         appNavigator: AppNavigator,
         userSettings: UserSettings = .shared,
         application: UIApplication) {
        self.presentedController = presentedController
        self.appNavigator = appNavigator
        self.userSettings = userSettings
        self.application = application
    }

    var muteView: MuteView {
        let viewModel = MuteViewModel(userSettings: userSettings)
        return MuteView(viewModel: viewModel)
    }

    var acknowledgmentsView: AcknowledgementView {
        return AcknowledgementView()
    }

    func openIndieAuthFlow(for urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        let me = url

        guard let indieAuthURL = IndieAuth.buildAuthorizationURL(forEndpoint: IndieAuth.Constants.authURL,
                                                           meUrl: me,
                                                           redirectURI: IndieAuth.Constants.callback,
                                                           clientId: IndieAuth.Constants.clientIDURL,
                                                           state: "") else {
                                                            return
        }

        application.open(indieAuthURL, options: [:], completionHandler: nil)
    }

    var mailView: MailView {
        MailView()
    }

    func logout() {
        presentedController.dismiss(animated: true, completion: nil)
        appNavigator.logout()
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode

        init(presentation: Binding<PresentationMode>) {
            _presentation = presentation
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            $presentation.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.setToRecipients(["icro@hartl.co"])
        viewController.setSubject("Icro support")
        viewController.mailComposeDelegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
