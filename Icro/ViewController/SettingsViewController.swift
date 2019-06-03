//
//  Created by martin on 20.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit

// swiftlint:disable type_body_length
final class SettingsViewController: UIViewController, LoadingViewController {
    private let navigator: SettingsNavigator
    private let mainNavigator: MainNavigator
    private let viewModel: SettingsViewModel
    private var cancelButton: UIBarButtonItem?
    @IBOutlet weak var outterStackView: UIStackView!
    @IBOutlet private weak var blogSetupView: UIView!

    @IBOutlet private weak var wordpressSettingsSwitchLabel: SettingsSwitchWithLabelView! {
        didSet {
            wordpressSettingsSwitchLabel.title = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGSETUPSWITCH_TEXT", comment: "")
            wordpressSettingsSwitchLabel.didSwitch = { [weak self] isOn in
                guard let self = self else { return }
                self.wordpressSwitchChanged(isOn: isOn)
            }
        }
    }
    @IBOutlet weak var wordpressURLTextInput: SettingsTextInputView! {
        didSet {
            wordpressURLTextInput.autocorrectionType = .no
            wordpressURLTextInput.contentType = .URL
            wordpressURLTextInput.placeholder = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGURLFIELD_PLACEHOLDER", comment: "")
            wordpressURLTextInput.shouldReturn = { [weak self] input in
                guard let self = self else { return true }
                return self.textInputShouldReturn(input: input)
            }
        }
    }

    @IBOutlet weak var wordpressUsernameTextInput: SettingsTextInputView! {
        didSet {
            wordpressUsernameTextInput.autocorrectionType = .no
            wordpressUsernameTextInput.placeholder = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGUSERNAMEFIELD_PLACEHOLDER", comment: "")
            wordpressUsernameTextInput.shouldReturn = { [weak self] input in
                guard let self = self else { return true }
                return self.textInputShouldReturn(input: input)
            }
        }
    }

    @IBOutlet weak var wordpressPasswordTextInput: SettingsTextInputView! {
        didSet {
            wordpressPasswordTextInput.contentType = .password
            wordpressPasswordTextInput.isSecureTextEntry = true
            wordpressPasswordTextInput.autocorrectionType = .no
            wordpressPasswordTextInput.placeholder = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGPASSWORDFIELD_PLACEHOLDER", comment: "")
            wordpressPasswordTextInput.shouldReturn = { [weak self] input in
                guard let self = self else { return true }
                return self.textInputShouldReturn(input: input)
            }

        }
    }

    @IBOutlet weak var micropubURLTextInput: SettingsTextInputView! {
        didSet {
            micropubURLTextInput.autocorrectionType = .no
            micropubURLTextInput.contentType = .URL
            micropubURLTextInput.placeholder = NSLocalizedString("SETTINGSVIEWCONTROLLER_MICROPUBURLFIELD_PLACEHOLDER", comment: "")
            micropubURLTextInput.shouldReturn = { [weak self] input in
                guard let self = self else { return true }
                return self.textInputShouldReturn(input: input)
            }
        }
    }

    @IBOutlet weak var micropubTokenTextInput: SettingsTextInputView! {
        didSet {
            micropubTokenTextInput.contentType = .password
            micropubTokenTextInput.isSecureTextEntry = true
            micropubTokenTextInput.autocorrectionType = .no
            micropubTokenTextInput.placeholder = NSLocalizedString("SETTINGSVIEWCONTROLLER_MICROPUBTOKENFIELD_PLACEHOLDER", comment: "")
            micropubTokenTextInput.shouldReturn = { [weak self] input in
                guard let self = self else { return true }
                return self.textInputShouldReturn(input: input)
            }
        }
    }

    @IBOutlet private weak var micropubSettingsSwitchLabel: SettingsSwitchWithLabelView! {
        didSet {
            micropubSettingsSwitchLabel.title = NSLocalizedString("SETTINGSVIEWCONTROLLER_MICROPUBSETUPSWITCH_TEXT", comment: "")
            micropubSettingsSwitchLabel.didSwitch = { [weak self] isOn in
                guard let self = self else { return }
                self.micropubSwitchChanged(isOn: isOn)
            }
        }
    }

    @IBOutlet private weak var micropubSetupView: UIView!
    @IBOutlet private weak var blogSectionHeaderView: SettingsSectionHeaderView! {
        didSet {
            blogSectionHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_BLOGSETUP_TITLE")
        }
    }
    @IBOutlet private weak var blogSetupInfoLabel: SettingsSectionSubtitleView! {
        didSet {
            blogSetupInfoLabel.title = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLOGINFO_TEXT", comment: "")
        }
    }

    @IBOutlet private weak var micropubSetupSectionHeaderView: SettingsSectionHeaderView! {
        didSet {
            micropubSetupSectionHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_MICROPUBSETUP_TITLE")
        }
    }
    @IBOutlet private weak var micropubSetupInfoLabel: SettingsSectionSubtitleView! {
        didSet {
            micropubSetupInfoLabel.title = NSLocalizedString("SETTINGSVIEWCONTROLLER_MICROPUBINFO_TEXT", comment: "")
        }
    }

    @IBOutlet private weak var accountSectionHeaderView: SettingsSectionHeaderView! {
        didSet {
            accountSectionHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_ACCOUNT_TITLE")
        }
    }
    @IBOutlet private weak var logoutButton: SettingsButton! {
        didSet {
            logoutButton.title = NSLocalizedString("SETTINGSVIEWCONTROLLER_LOGOUTBUTTON_TITLE", comment: "")
            logoutButton.didTap = { [weak self] in
                guard let self = self else { return }
                self.navigator.logout()
            }
        }
    }

    @IBOutlet private weak var contentSectionHeaderView: SettingsSectionHeaderView! {
        didSet {
            contentSectionHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_CONTENT_TITLE")
        }
    }

    @IBOutlet private weak var blacklistButton: SettingsButton! {
        didSet {
            blacklistButton.title = NSLocalizedString("SETTINGSVIEWCONTROLLER_BLACKLISTBUTTON_TITLE", comment: "")
            blacklistButton.didTap = { [weak self] in
                guard let self = self else { return }
                self.navigator.openBlacklist()
            }
        }
    }

    @IBOutlet private weak var guidlinesButton: SettingsButton! {
        didSet {
            guidlinesButton.title = NSLocalizedString("SETTINGSVIEWCONTROLLER_GUIDLINESBUTTON_TITLE", comment: "")
            guidlinesButton.didTap = { [weak self] in
                guard let self = self else { return }
                self.mainNavigator.openCommunityGuidlines()
            }
        }
    }

    @IBOutlet private weak var otherSectionHeaderView: SettingsSectionHeaderView! {
        didSet {
            otherSectionHeaderView.title = localizedString(key: "SETTINGSVIEWCONTROLLER_OTHER_TITLE")
        }
    }

    @IBOutlet private weak var hartlcoOnMicroBlogButton: SettingsButton! {
        didSet {
            hartlcoOnMicroBlogButton.title = NSLocalizedString("SETTINGSVIEWCONTROLLER_HARTLBUTTON_TITLE", comment: "")
            hartlcoOnMicroBlogButton.didTap = { [weak self] in
                guard let self = self else { return }
                self.navigator.openHartlCoOnMicroBlog()
            }
        }
    }

    @IBOutlet private weak var supportButton: SettingsButton! {
        didSet {
            supportButton.title = NSLocalizedString("SETTINGSVIEWCONTROLLER_SUPPORTBUTTON_TITLE", comment: "")
            supportButton.didTap = { [weak self] in
                guard let self = self else { return }
                self.navigator.openSupportMail()
            }
        }
    }

    @IBOutlet private weak var acknowledgmentsButton: SettingsButton! {
        didSet {
            acknowledgmentsButton.title = NSLocalizedString("SETTINGSVIEWCONTROLLER_ACKNOWLEDGMENTSBUTTON_TITLE", comment: "")
            acknowledgmentsButton.didTap = { [weak self] in
                guard let self = self else { return }
                self.navigator.openAcknowledgements()
            }
        }
    }

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
            tipJarSectionHeader.title = localizedString(key: "IN-APP-PURCHASE-TIP-JAR")
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

        updateState(animated: false)

        let tipJarView = TipJarView(viewModel: viewModel.tipJarViewModel)
        tipJarView.purchaseStateChanged = { [weak self] state in
            guard let self = self else { return }
            self.tipJarStateUpdated(state: state)
        }
        tipJarContainer.addSubview(tipJarView)
        tipJarView.pin(to: tipJarContainer)
    }

    func updateState(animated: Bool) {
        if let wordPressSetup = viewModel.wordPressSetup {
            wordpressSettingsSwitchLabel.isOn = true
            micropubSettingsSwitchLabel.isOn = false
            showBlogSetupView(show: true, animated: animated)
            wordpressURLTextInput.text = wordPressSetup.urlString
            wordpressUsernameTextInput.text = wordPressSetup.username
            wordpressPasswordTextInput.text = wordPressSetup.password
        } else if let micropubSetup = viewModel.micropubSetup {
            wordpressSettingsSwitchLabel.isOn = false
            micropubSettingsSwitchLabel.isOn = true
            showMicropubSetupView(show: true)
            micropubURLTextInput.text = micropubSetup.urlString
            micropubTokenTextInput.text = micropubSetup.micropubToken
        } else {
            wordpressSettingsSwitchLabel.isOn = false
            micropubSettingsSwitchLabel.isOn = false
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

    @objc private func cancel() {
        saveWordPressInfo()
        saveMicropubInfo()
        dismiss(animated: true, completion: nil)
    }

    private func wordpressSwitchChanged(isOn: Bool) {
        viewModel.wordPressSetup = nil
        resetInputs()

        micropubSettingsSwitchLabel.isOn = false
        showBlogSetupView(show: isOn)
    }

    private func micropubSwitchChanged(isOn: Bool) {
        viewModel.micropubSetup = nil
        resetInputs()

        wordpressSettingsSwitchLabel.isOn = false
        showMicropubSetupView(show: isOn)
    }

    @IBAction private func microBlogButtonPressed(_ sender: Any) {
        navigator.openMicroBlog()
    }

    fileprivate func saveWordPressInfo() {
        guard let username = wordpressUsernameTextInput.text.nonEmptyString,
            let password = wordpressPasswordTextInput.text.nonEmptyString,
            let urlString = wordpressURLTextInput.text.nonEmptyString else { return }
        let info = UserSettings.WordpressInfo(urlString: urlString, username: username, password: password)
        viewModel.wordPressSetup = info
    }

    fileprivate func saveMicropubInfo() {
        guard let urlString = micropubURLTextInput.text.nonEmptyString,
            let token = micropubTokenTextInput.text.nonEmptyString else { return }
        let info = UserSettings.MicropubInfo(urlString: urlString, micropubToken: token)
        viewModel.micropubSetup = info
    }

    private func resetInputs() {
        wordpressURLTextInput.text = ""
        wordpressUsernameTextInput.text = ""
        wordpressPasswordTextInput.text = ""
        micropubURLTextInput.text = ""
        micropubTokenTextInput.text = ""
    }

    private func tipJarStateUpdated(state: TipJarViewModel.State) {
        switch state {
        case .unloaded:
            return
        case .loading, .purchasing:
            showLoading(position: .top)
        case .loaded:
            hideMessage()
        case .purchased(let message):
            showMessage(text: message,
                        color: Color.successColor,
                        position: .top,
                        dismissalTime: .seconds(10))
        case .purchasingError(let error):
            showError(error: error, position: .top)
        case .cancelled:
            hideMessage()
        }
    }

}

extension SettingsViewController {
    func textInputShouldReturn(input: SettingsTextInputView) -> Bool {
        if input == wordpressURLTextInput {
            wordpressUsernameTextInput.becomeFirstResponder()
        } else if input == wordpressUsernameTextInput {
            wordpressPasswordTextInput.becomeFirstResponder()
        } else if input == wordpressPasswordTextInput {
            wordpressPasswordTextInput.resignFirstResponder()
            saveWordPressInfo()
        }

        if input == micropubURLTextInput {
            micropubTokenTextInput.becomeFirstResponder()
        } else if input == micropubTokenTextInput {
            micropubTokenTextInput.resignFirstResponder()
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

extension String {
    var nonEmptyString: String? {
        guard self != "" else { return nil }
        return self
    }
}

class SettingsCellView: UIView { }
class SettingsScrollView: UIScrollView { }
