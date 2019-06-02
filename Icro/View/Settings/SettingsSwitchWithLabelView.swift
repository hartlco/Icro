//
//  Created by Martin Hartl on 02.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

final class SettingsSwitchWithLabelView: UIView {
    private let label = UILabel(frame: .zero)
    private let toggle = UISwitch(frame: .zero)

    var title = "" {
        didSet {
            label.text = title
        }
    }

    var isOn = false {
        didSet {
            toggle.isOn = isOn
        }
    }

    var didSwitch: (Bool) -> Void = { _ in }

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
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        toggle.tintColor = Color.main

        addSubview(toggle)

        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        toggle.addTarget(self, action: #selector(didSwitchToggle), for: .valueChanged)

    }

    @objc private func didSwitchToggle() {
        didSwitch(toggle.isOn)
    }
}
