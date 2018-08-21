//
//  Created by martin on 18.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import SwiftMessages

extension UIViewController {
    func showLoading(position: SwiftMessages.PresentationStyle) {
        hideMessage()
        let view = MessageView.viewFromNib(layout: MessageView.Layout.statusLine)
        view.backgroundColor = Color.accent
        view.bodyLabel?.font = Font().loading
        view.bodyLabel?.text = "Loading"
        view.bodyLabel?.textColor = .white
        var config = SwiftMessages.Config()
        config.presentationStyle = position
        config.duration = .forever
        SwiftMessages.show(config: config, view: view)
    }

    func showError(position: SwiftMessages.PresentationStyle, error: Error) {
        hideMessage()
        let view = MessageView.viewFromNib(layout: MessageView.Layout.statusLine)
        view.backgroundColor = Color.main

        view.bodyLabel?.font = Font().loading
        view.bodyLabel?.text = error.text
        view.bodyLabel?.textColor = .white
        var config = SwiftMessages.Config()
        config.presentationStyle = position
        config.duration = .seconds(seconds: 4)
        SwiftMessages.show(config: config, view: view)
    }

    func hideMessage() {
        SwiftMessages.hide()
    }
}

private extension Error {
    var text: String {
        if let networkingError = self as? NetworkingError {
            switch networkingError {
            case .wordPressURLError:
                return "Invalid Wordpress setup"
            case .micropubURLError:
                return "Invalid micropub setup"
            case .invalidInput:
                return "Invalid input"
            default:
                return "Something went wrong, please try again"
            }
        }

        return "Something went wrong, please try again"
    }
}
