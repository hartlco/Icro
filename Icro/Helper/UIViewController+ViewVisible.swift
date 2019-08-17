//
//  Created by martin on 11.08.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit

@objc protocol ShortcutBackNavigateable {
    func setupNavigateBackShortcut(with notificationCenter: NotificationCenter)
}

extension UIViewController: ShortcutBackNavigateable {
    func setupNavigateBackShortcut(with notificationCenter: NotificationCenter) {
        notificationCenter.addObserver(self, selector: #selector(navigateBack), name: .mainMenuNavigateBack, object: nil)
    }

    @objc private func navigateBack() {
        guard isViewVisible else { return }

        navigationController?.popViewController(animated: true)
    }
}

extension UIViewController {
    var isViewVisible: Bool {
        return viewIfLoaded?.window != nil
    }
}
