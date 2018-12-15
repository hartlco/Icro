//
//  Created by martin on 01.05.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

final class KeyboardInputView: UIView {
    private var text: String? {
        didSet {
            guard let text = text, text.count > 0 else {
                characterCountLabel.text = ""
                return
            }

            characterCountLabel.text = "\(text.count)c"
        }
    }

    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!

    @IBOutlet private weak var characterCountLabel: UILabel!

    class func instanceFromNib() -> KeyboardInputView {
        let nib = UINib(nibName: "KeyboardInputView", bundle: Bundle(for: KeyboardInputView.self))
        // swiftlint:disable force_cast
        return nib.instantiate(withOwner: nil, options: nil)[0] as! KeyboardInputView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        text = nil
        linkButton.setTitle(localizedString(key: "KEYBOARDINPUTVIEW_LINKBUTTON_TTILE"), for: .normal)
        imageButton.setTitle(localizedString(key: "KEYBOARDINPUTVIEW_IMAGEBUTTON_TITLE"), for: .normal)
        postButton.setTitle(localizedString(key: "KEYBOARDINPUTVIEW_POSTBUTTON_TITLE"), for: .normal)
        update(for: "", numberOfImages: 0, imageState: .idle)
    }

    func update(for text: String, numberOfImages: Int, imageState: ImageState) {
        self.text = text

        switch imageState {
        case .idle:
            cancelButton.isHidden = true
            progressView.isHidden = true
            postButton.isEnabled = text.count > 0 || numberOfImages > 0
            imageButton.isEnabled = true
        case .uploading(let progress):
            postButton.isEnabled = false
            imageButton.isEnabled = false
            cancelButton.isHidden = false
            progressView.isHidden = false
            progressView.progress = progress
        }
    }
}
