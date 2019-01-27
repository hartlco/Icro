//
//  Created by martin on 20.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit

class SettingsViewController: UIViewController {
    private let navigator: SettingsNavigator
    private let mainNavigator: MainNavigator
    private let viewModel: SettingsViewModel
    private var cancelButton: UIBarButtonItem?
    @IBOutlet weak var outterStackView: UIStackView!
    @IBOutlet private weak var blogSetupView: UIView!
    @IBOutlet private weak var blogSetupSwitch: UISwitch!
    @IBOutlet private weak var blogSetupSwitchLabel: UILabel!
    @IBOutlet fileprivate weak var blogUrlTextField: UITextField! {
        didSet {
            blogUrlTextField.keyboardAppearance = Theme.currentTheme.keyboardAppearance
            blogUrlTextField.delegate = self
        }
    }
    @IBOutlet fileprivate weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.keyboardAppearance = Theme.currentTheme.keyboardAppearance
            usernameTextField.delegate = self
        }
    }
    @IBOutlet fileprivate weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.keyboardAppearance = Theme.currentTheme.keyboardAppearance
            passwordTextField.delegate = self
        }
    }
    @IBOutlet weak var micropubUrlTextField: UITextField! {
        didSet {
            micropubUrlTextField.keyboardAppearance = Theme.currentTheme.keyboardAppearance
            micropubTokenTextField.delegate = self
        }
    }
    @IBOutlet weak var micropubTokenTextField: UITextField! {
        didSet {
            micropubTokenTextField.keyboardAppearance = Theme.currentTheme.keyboardAppearance
            micropubTokenTextField.delegate = self
        }
    }

    @IBOutlet private weak var micropubSetupSwitch: UISwitch!
    @IBOutlet private weak var micropubSetupView: UIView!
    @IBOutlet private weak var micropubSetupSwitchLabel: UILabel!
    @IBOutlet private weak var blogSectionHeaderView: SettingsSectionHeaderView! {
        didSet {
            blogSectionHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_BLOGSETUP_TITLE")
        }
    }
    @IBOutlet private weak var blogSetupInfoLabel: UILabel!

    @IBOutlet private weak var micropubSetupSectionHeaderView: SettingsSectionHeaderView! {
        didSet {
            micropubSetupSectionHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_MICROPUBSETUP_TITLE")
        }
    }
    @IBOutlet private weak var micropubSetupInfoLabel: UILabel!

    @IBOutlet private weak var accountSectionHeaderView: SettingsSectionHeaderView! {
        didSet {
            accountSectionHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_ACCOUNT_TITLE")
        }
    }
    @IBOutlet private weak var logoutButton: FakeTableCellButton!
    @IBOutlet private weak var contentSectionHeaderView: SettingsSectionHeaderView! {
        didSet {
            contentSectionHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_CONTENT_TITLE")
        }
    }

    @IBOutlet private weak var blacklistButton: FakeTableCellButton!
    @IBOutlet private weak var guidlinesButton: FakeTableCellButton!
    @IBOutlet private weak var otherSectionHeaderView: SettingsSectionHeaderView! {
        didSet {
            otherSectionHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_OTHER_TITLE")
        }
    }

    @IBOutlet private weak var hartlcoOnMicroBlogButton: FakeTableCellButton!
    @IBOutlet private weak var supportButton: FakeTableCellButton!
    @IBOutlet private weak var acknowledgmentsButton: FakeTableCellButton!

    @IBOutlet private weak var appearanceHeaderView: SettingsSectionHeaderView! {
        didSet {
            appearanceHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_APPEARANCE_TITLE")
        }
    }
    @IBOutlet private weak var appearanceButtonWithText: SettingsButtonWithLabelView! {
        didSet {
            appearanceButtonWithText.buttonText = localizedString(key: "SETTINGSVIEWCONTROLLER_THEME_TITLE")
            appearanceButtonWithText.text = localizedString(key: UserSettings.shared.theme.rawValue)
            appearanceButtonWithText.didTap = { [weak self] in
                guard let self = self else { return }
                self.view.endEditing(true)
                self.navigator.openThemeSelector(sourceView: self.appearanceButtonWithText,
                                                  completion: { theme in
                                                    AppearanceManager.shared.switchTheme(to: theme)
                                                    self.appearanceButtonWithText.text = localizedString(key: theme.rawValue)
                })
            }
        }
    }

    @IBOutlet private weak var tipJarSectionHeader: SettingsSectionHeaderView! {
        didSet {
            tipJarSectionHeader.title = "Tip Jar"
        }
    }

    @IBOutlet private weak var tipJarContainer: UIView!

    init(navigator: SettingsNavigator,
         mainNavigator: MainNavigator,
         viewModel: SettingsViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.mainNavigator = mainNavigator
        super.init(nibName: String(describing: SettingsViewController.self), bundle: nil)
        self.cancelButton = UIBarButtonItem(title:
            NSLocalizedString("SETTINGSVIEWCONTROLLER_CANCELBUTTON_TITLE", comment: ""),
                                            style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("SETTINGSVIEWCONTROLLER_TITLE", comment: "")
        blogSetupSwitchLabel.text = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGSETUPSWITCH_TEXT", comment: "")
        blogUrlTextField.placeholder = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGURLFIELD_PLACEHOLDER", comment: "")
        usernameTextField.placeholder = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGUSERNAMEFIELD_PLACEHOLDER", comment: "")
        passwordTextField.placeholder = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGPASSWORDFIELD_PLACEHOLDER", comment: "")
        blogSetupInfoLabel.text = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGINFO_TEXT", comment: "")
        micropubSetupSwitchLabel.text = NSLocalizedString("SETTINGSVIEWCONTROLLER_MICROPUBSETUPSWITCH_TEXT", comment: "")
        micropubUrlTextField.placeholder = NSLocalizedString("SETTINGSVIEWCONTROLLER_MICROPUBURLFIELD_PLACEHOLDER", comment: "")
        micropubTokenTextField.placeholder = NSLocalizedString("SETTINGSVIEWCONTROLLER_MICROPUBTOKENFIELD_PLACEHOLDER", comment: "")
        micropubSetupInfoLabel.text = NSLocalizedString("SETTINGSVIEWCONTROLLER_MICROPUBINFO_TEXT", comment: "")

        logoutButton.setTitle(NSLocalizedString("SETTINGSVIEWCONTROLLER_LOGOUTBUTTON_TITLE", comment: ""), for: .normal)

        blacklistButton.setTitle(NSLocalizedString("SETTINGSVIEWCONTROLLER_BLACKLISTBUTTON_TITLE", comment: ""), for: .normal)
        guidlinesButton.setTitle(NSLocalizedString("SETTINGSVIEWCONTROLLER_GUIDLINESBUTTON_TITLE", comment: ""), for: .normal)
        hartlcoOnMicroBlogButton.setTitle(NSLocalizedString("SETTINGSVIEWCONTROLLER_HARTLBUTTON_TITLE", comment: ""), for: .normal)
        supportButton.setTitle(NSLocalizedString("SETTINGSVIEWCONTROLLER_SUPPORTBUTTON_TITLE", comment: ""), for: .normal)
        acknowledgmentsButton.setTitle(NSLocalizedString("SETTINGSVIEWCONTROLLER_ACKNOWLEDGMENTSBUTTON_TITLE", comment: ""), for: .normal)
        updateState(animated: false)

        let tipJarView = TipJarView(viewModel: viewModel.tipJarViewModel)
        tipJarContainer.addSubview(tipJarView)
        tipJarView.pin(to: tipJarContainer)
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
        mainNavigator.openCommunityGuidlines()
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

class SettingsSectionSubtitleView: UIView { }
class SettingsCellView: UIView { }
class SettingsTextInputView: UIView { }

class SettingsInlineSeparatorView: UIView {
    private let separator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = Color.separatorColor
        addSubview(separator)
        separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        separator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

class SettingsScrollView: UIScrollView { }

final class SettingsButtonWithLabelView: UIView {
    class SecondaryTextLabel: UILabel { }
    private var button: UIButton!
    private var label: SecondaryTextLabel!

    var didTap: (() -> Void) = { }
    var text = "" {
        didSet {
            label.text = text
        }
    }

    var buttonText = "" {
        didSet {
            button.setTitle(buttonText, for: .normal)
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
        backgroundColor = Color.backgroundColor
        label = SecondaryTextLabel(frame: CGRect.zero)
        button = UIButton(frame: CGRect.zero)
        addSubview(button)
        addSubview(label)
        translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = Color.secondaryTextColor
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }

    @objc private func didTapButton() {
        didTap()
    }
}

final class SettingsSectionHeaderView: UIView {
    private let label = UILabel(frame: CGRect.zero)

    var title = "" {
        didSet {
            label.text = title
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
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
