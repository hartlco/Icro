//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit
import DropdownTitleView

class ListViewController: UIViewController, LoadingViewController {
    @IBOutlet fileprivate weak var tableView: UITableView! {
        didSet {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(viewModel, action: #selector(ListViewModel.load), for: .valueChanged)
            tableView.register(UINib(nibName: ItemTableViewCell.identifer, bundle: Bundle(for: ItemTableViewCell.self)),
                               forCellReuseIdentifier: ItemTableViewCell.identifer)
            tableView.register(UINib(nibName: ProfileTableViewCell.identifier, bundle: nil),
                               forCellReuseIdentifier: ProfileTableViewCell.identifier)
            tableView.register(UINib(nibName: LoadMoreTableViewCell.identifier, bundle: nil),
                               forCellReuseIdentifier: LoadMoreTableViewCell.identifier)
            tableView.estimatedRowHeight = UITableView.automaticDimension
            tableView.rowHeight = UITableView.automaticDimension
            tableView.separatorColor = Color.separatorColor
        }
    }

    fileprivate let viewModel: ListViewModel
    fileprivate let cellConfigurator: ItemCellConfigurator
    fileprivate let itemNavigator: ItemNavigator
    fileprivate let profileViewConfigurator: ProfileViewConfigurator
    fileprivate let editActionsConfigurator: EditActionsConfigurator
    private var titleView: DropdownTitleView?

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

        NotificationCenter.default.addObserver(self, selector: #selector(refreshContent),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(refreshContent),
                                               name: .appearanceDidChange,
                                               object: nil)

        editActionsConfigurator.didModifyIndexPath = { [weak self] indexPath in
            self?.tableView.reloadData()
        }

        viewModel.didStartLoading = {
            self.isLoading = true
            self.showLoading()
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
            self?.showError(error: error)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.loadFromCache()

        if viewModel.shouldLoad {
            viewModel.load()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAppearance()

        updateDiscoverySectionsIfNeeded()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        rowHeightEstimate = [:]
        super.viewWillTransition(to: size, with: coordinator)
    }

    @objc private func refreshContent() {
        viewModel.resetContent()
        rowHeightEstimate = [:]
        tableView.reloadData()
    }

    private func updateDiscoverySectionsIfNeeded() {
        guard viewModel.showsDiscoverySections else { return }

        titleView = DropdownTitleView()

        updateAppearance()

        titleView?.configure(title: viewModel.title, subtitle: viewModel.discoverySubtitle)
        navigationItem.titleView = titleView
        titleView?.addTarget(
            self,
            action: #selector(onTitle),
            for: .touchUpInside
        )
    }

    @objc private func onTitle() {
        itemNavigator.showDiscoveryCategories(categories: viewModel.discoveryCategories, sourceView: titleView ?? view)
    }

    private func updateAppearance() {
        titleView?.titleColor = Color.textColor
        titleView?.subtitleColor = Color.secondaryTextColor
        view.backgroundColor = Color.backgroundColor
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.viewType(forRow: indexPath.row) {
        case .author(let author):
            return authorCell(for: author, in: tableView)
        case .loadMore:
            return loadMoreCell(at: indexPath, in: tableView)
        case .item(let item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.identifer,
                                                           for: indexPath) as? ItemTableViewCell else {
                                                            fatalError("Could not deque right cell")
            }

            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            cellConfigurator.configure(cell, forDisplaying: item)

            return cell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch viewModel.viewType(forRow: indexPath.row) {
        case .author, .loadMore:
            return
        case .item(let item):
            if isLoading == false {
                viewModel.set(lastReadRow: indexPath.row)
            }

            rowHeightEstimate[item.id] = cell.bounds.size.height

            updateUnread()
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.viewType(forRow: indexPath.row) {
        case .author, .loadMore:
            return UITableView.automaticDimension
        case .item(let item):
            return rowHeightEstimate[item.id] ?? UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.viewType(forRow: indexPath.row) {
        case .author, .loadMore:
            return UITableView.automaticDimension
        case .item(let item):
            return rowHeightEstimate[item.id] ?? UITableView.automaticDimension
        }
    }

    private func authorCell(for author: Author, in tableView: UITableView) -> ProfileTableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier)
        guard let cell = dequeuedCell as? ProfileTableViewCell else {
            fatalError()
        }
        profileViewConfigurator.configure(cell, using: author)
        return cell
    }

    private func loadMoreCell(at indexPath: IndexPath, in tableView: UITableView) -> LoadMoreTableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: LoadMoreTableViewCell.identifier)
        guard let cell = dequeuedCell as? LoadMoreTableViewCell else {
            fatalError()
        }
        cell.didPressLoadMore = { [weak self] in
            guard let self = self else { return }
            self.viewModel.loadMore(afterItemAtIndex: indexPath.row - 1)
        }
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return editActionsConfigurator.canEdit(at: indexPath)
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
