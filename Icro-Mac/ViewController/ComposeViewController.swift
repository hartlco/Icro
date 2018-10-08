//
//  ComposeViewController.swift
//  Icro-Mac
//

import Cocoa
import IcroKit_Mac

class ComposeViewController: NSViewController {
    @IBOutlet weak var composeTextField: NSTextField!

    private let viewModel: ComposeViewModel

    init(composeViewModel: ComposeViewModel) {
        self.viewModel = composeViewModel
        super.init(nibName: "ComposeViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        composeTextField.stringValue = viewModel.startText
        composeTextField.currentEditor()?.selectedRange = NSRange(location: 0, length: 0)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @IBAction func sendAction(_ sender: Any) {
        viewModel.post(string: composeTextField.stringValue) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(nil)
        }
    }

}
