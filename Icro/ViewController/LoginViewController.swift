//
//  Created by martin on 18.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var infoLabel: UIStackView!

    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: LoginViewController.self), bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Login"

        updateState()

        textField.addTarget(self, action: #selector(textFieldChanged), for: UIControlEvents.editingChanged)

        viewModel.updateState = { [weak self] in
            self?.updateState()
        }

        viewModel.didStartLoading = { [weak self] in
            self?.showLoading(position: .top)
        }

        viewModel.didFinishLoading = { [weak self] in
            self?.hideMessage()
        }

        viewModel.didFinishWithError = { [weak self] error in
            self?.showError(position: .top, error: error)

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
}
