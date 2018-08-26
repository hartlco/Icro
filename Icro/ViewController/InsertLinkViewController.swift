//
//  Created by martin on 13.05.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

class InsertLinkViewController: UIViewController, UITextFieldDelegate {
    var completion: ((String?, URL?) -> Void)?

    private var cancelButton: UIBarButtonItem?
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var insertButton: FakeTableCellButton!

    init() {
        super.init(nibName: "InsertLinkViewController", bundle: nil)
        title = NSLocalizedString("INSERTLINKVIEWCONTROLLER_TITLE", comment: "")
        cancelButton = UIBarButtonItem(title: NSLocalizedString("INSERTLINKVIEWCONTROLLER_CANCELBUTTON_TITLE", comment: ""),
                                       style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.becomeFirstResponder()
        titleTextField.placeholder = NSLocalizedString("INSERTLINKVIEWCONTROLLER_TITLETEXTFIELD_TEXT", comment: "")
        linkTextField.placeholder = NSLocalizedString("INSERTLINKVIEWCONTROLLER_LINKTEXTFIELD_TEXT", comment: "")
        insertButton.setTitle(NSLocalizedString("INSERTLINKVIEWCONTROLLER_INSERTBUTTON_TITLE", comment: ""), for: .normal)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            linkTextField.becomeFirstResponder()
        } else {
            insertButtonPressed(linkTextField)
        }

        return true
    }

    // MARK: - Private

    @objc private func cancel() {
        completion?(nil, nil)
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func insertButtonPressed(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let url = linkTextField.text ?? ""
        completion?(title, URL(string: url))
        dismiss(animated: true, completion: nil)
    }
}
