//
//  Created by martin on 18.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroUIKit

class LoginViewController: UIViewController, LoadingViewController {
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var textFieldInfo: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var infoLabel: UIStackView!
    @IBOutlet private weak var infoLabelText: UILabel!

    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: LoginViewController.self), bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("LOGINVIEWCONTROLLER_TITLE", comment: "")
        textField.placeholder = NSLocalizedString("LOGINVIEWCONTROLLER_TEXTFIELD_PLACEHOLDER", comment: "")
        textFieldInfo.text = NSLocalizedString("LOGINVIEWCONTROLLER_TEXTFIELDINFO_TEXT", comment: "")
        loginButton.setTitle( NSLocalizedString("LOGINVIEWCONTROLLER_LOGINBUTTON_TITLE", comment: ""), for: .normal)
        infoLabelText.text = NSLocalizedString("LOGINVIEWCONTROLLER_INFOLABEL_TEXT", comment: "")

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(cancelPressed))

        updateState()

        textField.addTarget(self, action: #selector(textFieldChanged), for: UIControl.Event.editingChanged)

        viewModel.updateState = { [weak self] in
            self?.updateState()
        }

        viewModel.didStartLoading = { [weak self] in
            self?.showLoading()
        }

        viewModel.didFinishLoading = { [weak self] in
            self?.hideMessage()
        }

        viewModel.didFinishWithError = { [weak self] error in
            self?.showError(error: error)

        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func verify(token: String) {
        viewModel.login(withToken: token)
    }

    private func updateState() {
        loginButton.isEnabled = viewModel.buttonActivated
        loginButton.setTitle(viewModel.buttonString, for: .normal)
        infoLabel.isHidden = !viewModel.infoLabelVisible
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        viewModel.login()
        textField.resignFirstResponder()
    }

    @objc private func textFieldChanged() {
        viewModel.loginString = textField.text ?? ""
    }

    @objc private func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }
}
