//
//  Created by Martin Hartl on 02.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

final class SettingsSectionSubtitleView: UIView {
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
        label.textColor = Color.secondaryTextColor
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        addSubview(label)
        label.pin(to: self, inset: UIEdgeInsets(top: 4, left: 10, bottom: 10, right: 10))
    }

}
