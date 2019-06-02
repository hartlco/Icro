//
//  Created by Martin Hartl on 12.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

final class SettingsSectionHeaderView: UIView {
    private let label = UILabel(frame: CGRect.zero)

    var title = "" {
        didSet {
            label.text = title
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
        translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Color.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
