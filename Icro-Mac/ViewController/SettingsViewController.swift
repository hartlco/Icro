//
//  SettingsViewController.swift
//  Icro-Mac
//

import Cocoa
import IcroKit_Mac

class SettingsViewController: NSViewController {
    @IBOutlet weak var microblogTokenTextField: NSTextField!
    @IBOutlet weak var micropubURLTextField: NSTextField!
    @IBOutlet weak var micropubTokenTextField: NSTextField!

    private let settings = UserSettings.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        microblogTokenTextField.stringValue = settings.token
        micropubURLTextField.stringValue = settings.micropubUrlString ?? ""
        micropubTokenTextField.stringValue = settings.micropubToken ?? ""

        preferredContentSize = NSSize(width: 400, height: 120)
    }

    override func viewWillDisappear() {
        settings.token = microblogTokenTextField.stringValue
        let url = micropubURLTextField.stringValue
        let token = micropubTokenTextField.stringValue
        if url != "", token != "" {
            settings.setMicropubInfo(info: UserSettings.MicropubInfo(urlString: url, micropubToken: token))
        }
    }
}
