//
//  Created by Martin Hartl on 02.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

final class SettingsSeparatorView: UIView {
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
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.pin(to: self)
    }
}
