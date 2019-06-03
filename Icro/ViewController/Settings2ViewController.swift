//
//  Created by Martin Hartl on 02.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit

class Settings2ViewController: UIViewController {
    private let scrollView = UIScrollView(frame: .zero)
    private let settingsView = SettingsView()
    private let contentView = UIView(frame: .zero)

    private let navigator: SettingsNavigator
    private let mainNavigator: MainNavigator
    private let viewModel: SettingsViewModel

    private weak var wordpressSwitchView: SettingsSwitchWithLabelView?
    private weak var wordpressURLTextInput: SettingsTextInputView?

    var showInput = false

    init(navigator: SettingsNavigator,
         mainNavigator: MainNavigator,
         viewModel: SettingsViewModel) {
        self.navigator = navigator
        self.viewModel = viewModel
        self.mainNavigator = mainNavigator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.pin(to: view)
        settingsView.sections = [appearanceSection, wordpressSection]

        scrollView.addSubview(contentView)
        contentView.backgroundColor = .clear
        contentView.pin(to: scrollView)

        contentView.addSubview(settingsView)
        settingsView.pin(to: contentView)
        settingsView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        // Do any additional setup after loading the view.
    }

    private var appearanceSection: SettingsSection {
        return SettingsSection(title: viewModel.appearanceTitle,
                               subTitle: nil,
                               cellTypes: [
                                .labelWithButton(configBlock: { [weak self] view in
                                    guard let self = self else { return }
                                    view.buttonText = self.viewModel.appearanceButtonText
                                    view.text = self.viewModel.appearanceText
                                    view.didTap = { [weak self] in
                                        guard let self = self else { return }
                                        self.view.endEditing(true)
                                        self.navigator.openThemeSelector(sourceView: view,
                                                                         completion: { theme in
                                                                            AppearanceManager.shared.switchTheme(to: theme)
                                                                            view.text = self.viewModel.appearanceText
                                        })
                                    }
                                })
            ])
    }

    private var wordpressSection: SettingsSection {
        let inputSettingsView = SettingsView(config: .init(appearance: .groupedFullWidth, hideTopBottomSeparators: true))
        let section = SettingsSection(title: nil, subTitle: nil, cellTypes: [
            .inputView(configBlock: { view in
                view.text = "Test"
            })
            ])
        inputSettingsView.sections = [section]

        return SettingsSection(title: viewModel.wordpressTitle,
                               subTitle: viewModel.wordpressSubTitle,
                               cellTypes: [
                                .labelWithSwitch(configBlock: { [weak self] view in
                                    guard let self = self else { return }
                                    self.wordpressSwitchView = view
                                    view.title = self.viewModel.wordpressSwitchTitle
                                    view.didSwitch = { [weak self] isOn in
                                        guard let self = self else { return }
                                        self.wordpressSwitchChanged(isOn: isOn)
                                        self.settingsView.update()
                                        self.showInput = isOn
                                    }
                                }),
                                .inputView(configBlock: { [weak self] view in
                                    guard let self = self else { return }
                                    self.wordpressURLTextInput = view
                                    view.autocorrectionType = .no
                                    view.contentType = .URL
                                    view.placeholder = Date().debugDescription
                                    view.shouldReturn = { [weak self] input in
                                        guard let self = self else { return true }
                                        return self.textInputShouldReturn(input: input)
                                    }
                                }),
                                .internalSettingsView(view: inputSettingsView, config: { view in
                                    view.isHidden = self.showInput
                                })

            ])
    }

    private func wordpressSwitchChanged(isOn: Bool) {
        viewModel.wordPressSetup = nil
        resetInputs()

//        micropubSettingsSwitchLabel.isOn = false
//        showBlogSetupView(show: isOn)
    }

    private func resetInputs() {
//        wordpressURLTextInput.text = ""
//        wordpressUsernameTextInput.text = ""
//        wordpressPasswordTextInput.text = ""
//        micropubURLTextInput.text = ""
//        micropubTokenTextInput.text = ""
    }
}

extension Settings2ViewController {
    func textInputShouldReturn(input: SettingsTextInputView) -> Bool {
//        if input == wordpressURLTextInput {
//            wordpressUsernameTextInput.becomeFirstResponder()
//        } else if input == wordpressUsernameTextInput {
//            wordpressPasswordTextInput.becomeFirstResponder()
//        } else if input == wordpressPasswordTextInput {
//            wordpressPasswordTextInput.resignFirstResponder()
//            saveWordPressInfo()
//        }
//
//        if input == micropubURLTextInput {
//            micropubTokenTextInput.becomeFirstResponder()
//        } else if input == micropubTokenTextInput {
//            micropubTokenTextInput.resignFirstResponder()
//            saveMicropubInfo()
//        }

        return true
    }
}
