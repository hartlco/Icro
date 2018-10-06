//
//  SplitViewController.swift
//  Icro-Mac
//
//  Created by martin on 06.10.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
    @IBOutlet weak var menuPane: NSSplitViewItem!
    @IBOutlet weak var contentPane: NSSplitViewItem!

    private var tabViewController: TabViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        tabViewController = menuPane.viewController as? TabViewController

        tabViewController?.didSelectTab = { [weak self] viewModel in
            guard let self = self else { return }
            self.removeChild(at: 1)
            self.addChild(ListViewController(listViewModel: viewModel))
        }
    }
    
}
