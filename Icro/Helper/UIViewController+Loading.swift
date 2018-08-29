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
        view.bodyLabel?.text = NSLocalizedString("UIVIEWCONTROLLERLOADING_LOADING_TEXT", comment: "")
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
                return NSLocalizedString("UIVIEWCONTROLLERLOADING_WORDPRESSURLERROR_TEXT", comment: "")
            case .micropubURLError:
                return NSLocalizedString("UIVIEWCONTROLLERLOADING_MICROPUBURLERROR_TEXT", comment: "")
            case .invalidInput:
                return NSLocalizedString("UIVIEWCONTROLLERLOADING_INVALIDINPUT_TEXT", comment: "")
            default:
                return NSLocalizedString("UIVIEWCONTROLLERLOADING_ERROR_TEXT", comment: "")
            }
        }

        return NSLocalizedString("UIVIEWCONTROLLERLOADING_ERROR_TEXT", comment: "")
    }
}
