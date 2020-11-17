//
//  Created by martin on 20.07.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import SwiftUI
import VerticalTabView

final class VerticalTabsSplitViewController: UISplitViewController {
    private let verticalTabView: VerticalTabView
    private let tabBarViewController: TabBarViewController
    private let hostingController: UIHostingController<VerticalTabView>

    var shouldIncludeBarInExtendedLayout = true

    init(verticalTabView: VerticalTabView,
         tabBarViewController: TabBarViewController) {
        self.verticalTabView = verticalTabView
        self.tabBarViewController = tabBarViewController
        self.hostingController = UIHostingController(rootView: verticalTabView)
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [hostingController, tabBarViewController]
        tabBarViewController.tabBar.isHidden = true
        preferredDisplayMode = .oneBesideSecondary
        maximumPrimaryColumnWidth = 92.0
        minimumPrimaryColumnWidth = 92.0
    }

    override var canBecomeFirstResponder: Bool {
        return false
    }
}

extension VerticalTabsSplitViewController: UISplitViewControllerDelegate {
    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        tabBarViewController.tabBar.isHidden = false
        shouldIncludeBarInExtendedLayout = false
        tabBarViewController.extendedLayoutIncludesOpaqueBars = false
        return tabBarViewController
    }

    func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        tabBarViewController.tabBar.isHidden = true
        shouldIncludeBarInExtendedLayout = true
        tabBarViewController.extendedLayoutIncludesOpaqueBars = true
        return hostingController
    }
}
