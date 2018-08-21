//
//  Created by martin on 20.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    private let navigator: SettingsNavigator
    private let itemNavigator: ItemNavigator
    private let viewModel: SettingsViewModel
    private var cancelButton: UIBarButtonItem?
    @IBOutlet weak var outterStackView: UIStackView!
    @IBOutlet private weak var blogSetupView: UIView!
    @IBOutlet private weak var blogSetupSwitch: UISwitch!
    @IBOutlet fileprivate weak var blogUrlTextField: UITextField! {
        didSet {
            blogUrlTextField.delegate = self
        }
    }
    @IBOutlet fileprivate weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.delegate = self
        }
    }
    @IBOutlet fileprivate weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    @IBOutlet weak var micropubUrlTextField: UITextField! {
        didSet {
            micropubTokenTextField.delegate = self
        }
    }
    @IBOutlet weak var micropubTokenTextField: UITextField! {
        didSet {
            micropubTokenTextField.delegate = self
        }
    }

    @IBOutlet private weak var micropubSetupSwitch: UISwitch!
    @IBOutlet private weak var micropubSetupView: UIView!

    init(navigator: SettingsNavigator,
         itemNavigator: ItemNavigator,
         viewModel: SettingsViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.itemNavigator = itemNavigator
        super.init(nibName: String(describing: SettingsViewController.self), bundle: nil)
        self.cancelButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        updateState(animated: false)
    }

    func updateState(animated: Bool) {
        if let wordPressSetup = viewModel.wordPressSetup {
            blogSetupSwitch.isOn = true
            micropubSetupSwitch.isOn = false
            showBlogSetupView(show: true, animated: animated)
            blogUrlTextField.text = wordPressSetup.urlString
            usernameTextField.text = wordPressSetup.username
            passwordTextField.text = wordPressSetup.password
        } else if let micropubSetup = viewModel.micropubSetup {
            blogSetupSwitch.isOn = false
            micropubSetupSwitch.isOn = true
            showMicropubSetupView(show: true)
            micropubUrlTextField.text = micropubSetup.urlString
            micropubTokenTextField.text = micropubSetup.micropubToken
        } else {
            blogSetupSwitch.isOn = false
            micropubSetupSwitch.isOn = false
            showBlogSetupView(show: false, animated: animated)
            showMicropubSetupView(show: false)
            resetInputs()
        }
    }

    func showBlogSetupView(show: Bool, animated: Bool = false) {
        guard animated else {
            blogSetupView.isHidden = !show
            self.micropubSetupView.isHidden = true
            return
        }

        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: {
                        self.blogSetupView.isHidden = !show
                        self.micropubSetupView.isHidden = true
                        self.outterStackView.layoutIfNeeded()
                        }, completion: nil)
    }

    func showMicropubSetupView(show: Bool, animated: Bool = false) {
        guard animated else {
            micropubSetupView.isHidden = !show
            blogSetupView.isHidden = true
            return
        }

        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: {
                        self.micropubSetupView.isHidden = !show
                        self.blogSetupView.isHidden = true
                        self.outterStackView.layoutIfNeeded()
        }, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBAction func acknowledgmentsButtonPressed(_ sender: Any) {
        navigator.openAcknowledgements()
    }

    @objc private func cancel() {
        saveWordPressInfo()
        saveMicropubInfo()
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func blogSetupSwitchChanged(_ sender: Any) {
        viewModel.wordPressSetup = nil
        resetInputs()

        micropubSetupSwitch.isOn = false
        showBlogSetupView(show: blogSetupSwitch.isOn)
    }

    @IBAction func micropubSwitchChanged(_ sender: Any) {
        viewModel.micropubSetup = nil
        resetInputs()

        blogSetupSwitch.isOn = false
        showMicropubSetupView(show: micropubSetupSwitch.isOn)
    }

    @IBAction private func hartlcoOnMicroBlogButtonPressed(_ sender: Any) {
        navigator.openHartlCoOnMicroBlog()
    }

    @IBAction private func microBlogButtonPressed(_ sender: Any) {
        navigator.openMicroBlog()
    }

    @IBAction private func supportButtonPressed(_ sender: Any) {
        navigator.openSupportMail()
    }

    @IBAction private func logoutButtonPressed(_ sender: Any) {
        navigator.logout()
    }

    @IBAction private func blacklistButtonPressed(_ sender: Any) {
        navigator.openBlacklist()
    }

    @IBAction private func communityGuidlinesPressed(_ sender: Any) {
        itemNavigator.openCommunityGuidlines()
    }

    fileprivate func saveWordPressInfo() {
        guard let username = usernameTextField.nonEmptyText,
            let password = passwordTextField.nonEmptyText, let urlString = blogUrlTextField.nonEmptyText else { return }
        let info = UserSettings.WordpressInfo(urlString: urlString, username: username, password: password)
        viewModel.wordPressSetup = info
    }

    fileprivate func saveMicropubInfo() {
        guard let urlString = micropubUrlTextField.nonEmptyText,
            let token = micropubTokenTextField.nonEmptyText else { return }
        let info = UserSettings.MicropubInfo(urlString: urlString, micropubToken: token)
        viewModel.micropubSetup = info
    }

    private func resetInputs() {
        blogUrlTextField.text = ""
        usernameTextField.text = ""
        passwordTextField.text = ""
        micropubUrlTextField.text = ""
        micropubTokenTextField.text = ""
    }

}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == blogUrlTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            saveWordPressInfo()
        }

        if textField == micropubUrlTextField {
            micropubTokenTextField.becomeFirstResponder()
        } else if textField == micropubTokenTextField {
            micropubTokenTextField.resignFirstResponder()
            saveMicropubInfo()
        }

        return true
    }
}

fileprivate extension UITextField {
    var nonEmptyText: String? {
        guard let text = text, text != "" else { return nil }
        return text
    }
}
