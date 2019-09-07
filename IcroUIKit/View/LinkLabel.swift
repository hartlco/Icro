//
//  Created by martin on 15.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

class LinkLabel: UILabel {
    /// Called on a detected touch on the Label. If a link was touched, the URL is passed.
    var didTap: ((URL?) -> Void)?

    func set(attributedText: NSAttributedString) {
        self.attributedText = attributedText
        if touchRecognizer == nil {
            touchRecognizer  = UITapGestureRecognizer(target: self, action: #selector(didTapText(recognizer:)))
            addGestureRecognizer(touchRecognizer!)
        }
    }

    private var touchRecognizer: UITapGestureRecognizer?

    @objc private func didTapText(recognizer: UITapGestureRecognizer) {
        guard let text = attributedText else { return }

        var didDetectLink = false

        text.enumerateAttributes(in: NSRange(location: 0, length: text.length), options: []) { [weak self] (attributes, rane, _) in
            guard let strongSelf = self else { return }

            let links = attributes.filter({ key, _ in
                return key == NSAttributedString.Key(rawValue: "IcroLinkAttribute")
            })

            links.forEach({ _, value in
                if recognizer.didTapAttributedTextInLabel(label: strongSelf, inRange: rane),
                    let url = value as? URL {
                    strongSelf.didTap?(url)
                    didDetectLink = true
                }
            })
        }

        if didDetectLink == false {
            didTap?(nil)
        }
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
