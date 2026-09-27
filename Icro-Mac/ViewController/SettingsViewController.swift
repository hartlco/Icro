//
//  SettingsViewController.swift
//  Icro-Mac
//

import Cocoa
import IcroKit_Mac

class SettingsViewController: NSViewController {
    @IBOutlet weak var microblogTokenTextField: NSTextField!

    private let settings = UserSettings.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        microblogTokenTextField.stringValue = settings.token
        preferredContentSize = NSSize(width: 400, height: 70)
    }

    override func viewWillDisappear() {
        settings.token = microblogTokenTextField.stringValue
    }
}
