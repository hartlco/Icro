//
//  Created by martin on 11.05.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

public class FakeTableCellButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        generalInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        generalInit()
    }

    private func generalInit() {
        titleLabel?.adjustsFontForContentSizeCategory = true
        NotificationCenter.default.addObserver(self, selector: #selector(textSizeChanged),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    @objc private func textSizeChanged() {
        titleLabel?.sizeToFit()
        sizeToFit()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
