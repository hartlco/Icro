//
//  Created by martin on 04.08.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI

final class VerticalTabAwareHostingController<Content: View>: UIHostingController<Content> {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAppearance()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateAppearance()
    }

    private func updateAppearance() {
        if let splitViewController = splitViewController as? VerticalTabsSplitViewController {
            extendedLayoutIncludesOpaqueBars = splitViewController.shouldIncludeBarInExtendedLayout
        }
    }
}
