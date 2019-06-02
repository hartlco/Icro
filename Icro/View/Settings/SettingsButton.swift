//
//  Created by Martin Hartl on 02.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroUIKit

final class SettingsButton: UIView {
    private let button = FakeTableCellButton(frame: .zero)

    var title = "" {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }

    var didTap: () -> Void = { }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addSubview(button)
        button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.pin(to: self)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    @objc private func didTapButton() {
        didTap()
    }
}
