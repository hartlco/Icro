//
//  Created by martin on 11.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: UserItemTableViewCell.identifier, bundle: nil),
                               forCellReuseIdentifier: UserItemTableViewCell.identifier)
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
            self?.showLoading(position: .bottom)
        }

        viewModel.didFinishLoading = { [weak self] in
            self?.hideMessage()
            self?.tableView.reloadData()
        }

        viewModel.didFinishWithError = { [weak self] error in
            self?.showError(position: .bottom, error: error)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserItemTableViewCell.identifier,
                                                       for: indexPath) as? UserItemTableViewCell else {
            fatalError()
        }
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
