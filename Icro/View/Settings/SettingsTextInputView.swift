//
//  Created by Martin Hartl on 02.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

final class SettingsTextInputView: UIView {
    private let textField: UITextField = UITextField(frame: .zero)

    var placeholder: String? {
        get {
            return textField.placeholder
        }

        set {
            textField.attributedPlaceholder =
                NSAttributedString(string: newValue ?? "",
                                   attributes: [NSAttributedString.Key.foregroundColor: Color.secondaryTextColor])
        }
    }

    var text: String {
        set {
            textField.text = newValue
        }

        get {
            return textField.text ?? ""
        }
    }

    var shouldReturn: (SettingsTextInputView) -> Bool = { _ in
        return true
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    @discardableResult override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
        return true
    }

    var contentType: UITextContentType? {
        set {
            textField.textContentType = newValue
        }

        get {
            return textField.textContentType
        }
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        set {
            textField.autocapitalizationType = newValue
        }

        get {
            return textField.autocapitalizationType
        }
    }

    var autocorrectionType: UITextAutocorrectionType {
        set {
            textField.autocorrectionType = newValue
        }

        get {
            return textField.autocorrectionType
        }
    }

    var isSecureTextEntry: Bool {
        set {
            textField.isSecureTextEntry = newValue
        }

        get {
            return textField.isSecureTextEntry
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .preferredFont(forTextStyle: .subheadline)
        textField.pin(to: self, inset: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0))
        textField.keyboardAppearance = Theme.currentTheme.keyboardAppearance
        textField.delegate = self
    }
}

extension SettingsTextInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return shouldReturn(self)
    }
}
