//
//  Created by Martin Hartl on 12.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

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
