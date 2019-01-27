//
//  Created by martin on 13.05.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

public class InsertLinkViewController: UIViewController, UITextFieldDelegate {
    public var completion: ((String?, URL?) -> Void)?

    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var linkTextField: UITextField!
    @IBOutlet private weak var insertButton: FakeTableCellButton!

    public init() {
        super.init(nibName: "InsertLinkViewController", bundle: Bundle(for: InsertLinkViewController.self))
        title = localizedString(key: "INSERTLINKVIEWCONTROLLER_TITLE")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.becomeFirstResponder()
        titleTextField.placeholder = localizedString(key: "INSERTLINKVIEWCONTROLLER_TITLETEXTFIELD_TEXT")
        linkTextField.placeholder = localizedString(key: "INSERTLINKVIEWCONTROLLER_LINKTEXTFIELD_TEXT")
        insertButton.setTitle(localizedString(key: "INSERTLINKVIEWCONTROLLER_INSERTBUTTON_TITLE"), for: .normal)
    }

    // MARK: - UITextFieldDelegate

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            linkTextField.becomeFirstResponder()
        } else {
            insertButtonPressed(linkTextField)
        }

        return true
    }

    // MARK: - Private

    @IBAction private func insertButtonPressed(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let url = linkTextField.text ?? ""
        completion?(title, URL(string: url))
        navigationController?.popViewController(animated: true)
    }
}
