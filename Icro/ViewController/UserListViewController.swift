//
//  Created by martin on 11.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroUIKit
import Dequeueable

class UserListViewController: UIViewController, LoadingViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(cellType: UserItemTableViewCell.self)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    private let cellConfigurator = UserItemCellConfigurator()
    private let viewModel: UserListViewModel
    private let itemNavigator: ItemNavigator

    init(viewModel: UserListViewModel,
         itemNavigator: ItemNavigator) {
        self.viewModel = viewModel
        self.itemNavigator = itemNavigator
        super.init(nibName: String(describing: UserListViewController.self), bundle: nil)

        title = NSLocalizedString("USERLISTVIEWCONTROLLER_TITLE", comment: "")

        viewModel.didStartLoading = { [weak self] in
            self?.showLoading()
        }

        viewModel.didFinishLoading = { [weak self] in
            self?.hideMessage()
            self?.tableView.reloadData()
        }

        viewModel.didFinishWithError = { [weak self] error in
            self?.showError(error: error)
        }

        viewModel.load()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfUsers
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: UserItemTableViewCell.self, for: indexPath)
        let user = viewModel.user(for: indexPath.row)
        cellConfigurator.configure(cell: cell, for: user)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let author = viewModel.user(for: indexPath.row)
        itemNavigator.open(author: author)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
