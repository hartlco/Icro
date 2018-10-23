//
//  SplitViewController.swift
//  Icro-Mac
//
//  Created by martin on 06.10.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Cocoa
import IcroKit_Mac

class SplitViewController: NSSplitViewController {
    @IBOutlet weak var menuPane: NSSplitViewItem!
    @IBOutlet weak var contentPane: NSSplitViewItem!

    private var tabViewController: TabViewController?
    private var viewControllersByViewModel = [ListViewModel: ListViewController]()

    override func viewWillAppear() {
        super.viewWillAppear()

        let itemNavigator = ItemNavigator()

        tabViewController = menuPane.viewController as? TabViewController

        tabViewController?.didSelectTab = { [weak self] viewModel in
            guard let self = self else { return }
            self.removeChild(at: 1)
            self.addChild(self.viewController(for: viewModel, itemNavigator: itemNavigator))
        }
    }

    @IBAction private func newPost(sender: Any) {
        ItemNavigator().openCompose()
    }

    @IBAction private func refreshTimeline(_ sender: Any) {
        guard let currentListViewController = children.last as? ListViewController else { return }
        currentListViewController.refresh()
    }

    @IBAction private func openSettings(_ sender: Any) {
        ItemNavigator().openSettings()
    }

    @IBAction private func showTimeline(_ sender: Any) {
        tabViewController?.selectTab(index: 0)
    }

    @IBAction private func showMentions(_ sender: Any) {
        tabViewController?.selectTab(index: 1)
    }

    @IBAction private func showFavorites(_ sender: Any) {
        tabViewController?.selectTab(index: 2)
    }

    @IBAction private func showDiscover(_ sender: Any) {
        tabViewController?.selectTab(index: 3)
    }

    @IBAction private func showProfile(_ sender: Any) {
        tabViewController?.selectTab(index: 4)
    }

    // MARK: - Private

    private func viewController(for viewModel: ListViewModel, itemNavigator: ItemNavigator) -> ListViewController {
        if let viewController = viewControllersByViewModel[viewModel] {
            return viewController
        }

        let viewController = ListViewController(listViewModel: viewModel, itemNavigator: itemNavigator)
        viewControllersByViewModel[viewModel] = viewController
        return viewController
    }
}
