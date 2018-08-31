//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import SwiftMessages

class ListViewController: UIViewController {
    @IBOutlet fileprivate weak var tableView: UITableView! {
        didSet {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(viewModel, action: #selector(ListViewModel.load), for: .valueChanged)
            tableView.register(UINib(nibName: ItemTableViewCell.identifer, bundle: nil),
                               forCellReuseIdentifier: ItemTableViewCell.identifer)
            tableView.register(UINib(nibName: ProfileTableViewCell.identifier, bundle: nil),
                               forCellReuseIdentifier: ProfileTableViewCell.identifier)
            tableView.estimatedRowHeight = UITableViewAutomaticDimension
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }

    fileprivate let viewModel: ListViewModel
    fileprivate let cellConfigurator: ItemCellConfigurator
    fileprivate let itemNavigator: ItemNavigator
    fileprivate let profileViewConfigurator: ProfileViewConfigurator
    fileprivate let editActionsConfigurator: EditActionsConfigurator

    @IBOutlet private weak var unreadView: UIView!
    @IBOutlet weak var unreadLabel: UILabel!
    var isLoading = false

    fileprivate var rowHeightEstimate = [String: CGFloat]()

    init(viewModel: ListViewModel,
         itemNavigator: ItemNavigator) {
        self.viewModel = viewModel
        self.itemNavigator = itemNavigator
        cellConfigurator = ItemCellConfigurator(itemNavigator: itemNavigator)
        profileViewConfigurator = ProfileViewConfigurator(itemNavigator: itemNavigator, viewModel: viewModel)
        editActionsConfigurator = EditActionsConfigurator(itemNavigator: itemNavigator, viewModel: viewModel)

        super.init(nibName: "ListViewController", bundle: nil)

        title = viewModel.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUnread()

        NotificationCenter.default.addObserver(self, selector: #selector(textSizeChanged),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(axPresentLinks(_:)),
        name: NSNotification.Name(rawValue: "axActions"),
                                               object: nil)

        editActionsConfigurator.didModifyIndexPath = { [weak self] indexPath in
            self?.tableView.reloadData()
        }

        viewModel.didStartLoading = {
            self.isLoading = true
            self.showLoading(position: .bottom)
        }

        viewModel.didFinishLoading = { [weak self] cache in
            if cache == false {
                self?.tableView.refreshControl?.endRefreshing()
                self?.hideMessage()
            }

            self?.tableView.reloadData()
            if let newIndex = self?.viewModel.numberOfUnreadItems {
                self?.updateUnread()
                self?.tableView.scrollToRow(at: IndexPath(row: newIndex, section: 0), at: .top, animated: false)
            }
            self?.isLoading = false
        }

        viewModel.didFinishWithError = { [weak self] error in
            self?.tableView.refreshControl?.endRefreshing()
            self?.showError(position: .bottom, error: error)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel.shouldLoad {
            viewModel.load()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        rowHeightEstimate = [:]
        super.viewWillTransition(to: size, with: coordinator)
    }

    @objc private func axPresentLinks(_ notification: NSNotification) {
        if let linkList = notification.userInfo?["links"] as? [(text: String, url: URL)] {
            let message = notification.userInfo?["message"] as? String

            let linksActionSheet = UIAlertController(title: "Links", message: message, preferredStyle: UIAlertControllerStyle.actionSheet)

            for (value) in linkList {
                let linkAction = UIAlertAction(title: value.text, style: UIAlertActionStyle.default) { (action) in
                    self.itemNavigator.open(url: value.url)
                }
                linksActionSheet.addAction(linkAction)
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            }
            linksActionSheet.addAction(cancelAction)

            // support iPad
            linksActionSheet.popoverPresentationController?.sourceView = self.view
            linksActionSheet.popoverPresentationController?.sourceRect = self.view.bounds

            self.present(linksActionSheet, animated: true, completion: nil)
        }
    }

    @objc private func textSizeChanged() {
        viewModel.resetContent()
        rowHeightEstimate = [:]
        tableView.reloadData()
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let items = indexPaths.compactMap { [weak self] indexPath in
            self?.viewModel.item(for: indexPath.row)
        }
        cellConfigurator.prefetchCells(for: items)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if case .author(let author) = viewModel.viewType(for: indexPath.section, row: indexPath.row) {
            return authorCell(for: author, in: tableView)
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.identifer,
                                                       for: indexPath) as? ItemTableViewCell else {
            fatalError("Could not deque right cell")
        }

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        let item = viewModel.item(for: indexPath.row)
        cellConfigurator.configure(cell, forDisplaying: item)

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if case .author(_) = viewModel.viewType(for: indexPath.section, row: indexPath.row) {
            return
        }

        if isLoading == false {
            viewModel.set(lastReadRow: indexPath.row)
        }

        let item = viewModel.item(for: indexPath.row)
        rowHeightEstimate[item.id] = cell.bounds.size.height

        updateUnread()
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if case .author(_) = viewModel.viewType(for: indexPath.section, row: indexPath.row) {
            return UITableViewAutomaticDimension
        }

        let item = viewModel.item(for: indexPath.row)
        return rowHeightEstimate[item.id] ?? UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if case .author(_) = viewModel.viewType(for: indexPath.section, row: indexPath.row) {
            return UITableViewAutomaticDimension
        }

        let item = viewModel.item(for: indexPath.row)
        return rowHeightEstimate[item.id] ?? UITableViewAutomaticDimension
    }

    private func authorCell(for author: Author, in tableView: UITableView) -> ProfileTableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier)
        guard let cell = dequeuedCell as? ProfileTableViewCell else {
            fatalError()
        }
        profileViewConfigurator.configure(cell, using: author)
        return cell
    }

    private func updateUnread() {
        guard let count = viewModel.numberOfUnreadItems else {
            unreadView.isHidden = true
            return
        }
        unreadLabel.text = String(count)

        if count == 0 {
            unreadView.isHidden = true
        } else {
            unreadView.isHidden = false
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return editActionsConfigurator.tralingEditActions(at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return editActionsConfigurator.leadingEditActions(at: indexPath, in: tableView)
    }
}

extension ListViewController: ScrollToTop {
    func scrollToTop() {
        guard tableView.numberOfRows(inSection: 0) > 0 else { return }
        viewModel.resetScrollPosition()
        updateUnread()
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}
