//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import Style
import DropdownTitleView
import SwiftUI

final class ListViewController: UIViewController, LoadingViewController {
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.separatorColor = Color.separatorColor
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(viewModel, action: #selector(ListViewModel.load), for: .valueChanged)
        tableView.register(cellType: ItemTableViewCell.self)
        tableView.register(cellType: ProfileTableViewCell.self)
        tableView.registerClass(cellType: LoadMoreTableViewCell.self)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = Color.separatorColor

        return tableView
    }()

    private let viewModel: ListViewModel
    private let cellConfigurator: ItemCellConfigurator
    private let itemNavigator: ItemNavigatorProtocol
    private let profileViewConfigurator: ProfileViewConfigurator
    private let editActionsConfigurator: EditActionsConfigurator
    private var titleView: DropdownTitleView?
    private typealias DiffableDataSource = EditableTableViewDiffableDataSource

    private let unreadView: UnreadView = {
        let view = UnreadView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var isLoading = false
    private var rowHeightEstimate = [String: CGFloat]()
    private let notificationCenter: NotificationCenter
    private let loadingSpinner = UIActivityIndicatorView(style: .medium)
    private let loadingBarButtonItem: UIBarButtonItem

    private let loginOverlayHostingViewController: UIHostingController<LoginOverlayView>

    private var dataSource: UITableViewDiffableDataSource<ListViewModel.Section, ListViewModel.ViewType>?

    init(viewModel: ListViewModel,
         itemNavigator: ItemNavigatorProtocol,
         notificationCenter: NotificationCenter = .default) {
        self.viewModel = viewModel
        self.itemNavigator = itemNavigator
        cellConfigurator = ItemCellConfigurator(itemNavigator: itemNavigator)
        profileViewConfigurator = ProfileViewConfigurator(itemNavigator: itemNavigator, viewModel: viewModel)
        editActionsConfigurator = EditActionsConfigurator(itemNavigator: itemNavigator, viewModel: viewModel)
        self.notificationCenter = notificationCenter
        self.loadingBarButtonItem = UIBarButtonItem(customView: loadingSpinner)
        self.loginOverlayHostingViewController = UIHostingController(
            rootView: LoginOverlayView { [weak itemNavigator] in
                itemNavigator?.showLogin()
            }
        )

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title

        view.addSubview(tableView)
        view.addSubview(unreadView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            unreadView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UnreadView.Constants.mainViewLeading),
            unreadView.topAnchor.constraint(equalTo: view.topAnchor, constant: -UnreadView.Constants.cornerRadius)
        ])

        tableView.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
        setupMainMenuNotification()
        updateUnread()

        notificationCenter.addObserver(self, selector: #selector(refreshContent),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)

        viewModel.didStartLoading = { [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            self.showLoadingSpinnerIfNeeded()
        }

        viewModel.didFinishLoading = { [weak self] cache in
            if cache == false {
                self?.hideLoadingSpinner()
                self?.tableView.refreshControl?.endRefreshing()
            }

            self?.applySnapshot()
            if let newIndex = self?.viewModel.numberOfUnreadItems, newIndex != 0 {
                self?.updateUnread()
                self?.tableView.scrollToRow(at: IndexPath(row: newIndex, section: 0), at: .top, animated: false)
            }
            self?.isLoading = false
        }

        viewModel.didFinishWithError = { [weak self] error in
            self?.showError(error: error)
        }

        setupNavigateBackShortcut(with: notificationCenter)

        // Hide empty cells
        tableView.tableFooterView = UIView(frame: .zero)
    }

    deinit {
        notificationCenter.removeObserver(self)
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

        if viewModel.showsLoginView {
            showLoginOverlay()
        } else {
            hideLoginOverlay()
        }

        navigationItem.rightBarButtonItem?.isEnabled = viewModel.barButtonEnabled
        navigationItem.leftBarButtonItem?.isEnabled = viewModel.barButtonEnabled
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateAppearance()
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

    @IBAction private func loginPressed(_ sender: Any) {
        itemNavigator.showLogin()
    }

    private func setupDataSource() {
        dataSource = DiffableDataSource(tableView: tableView,
                                        cellProvider: { [weak self] tableView, indexPath, item -> UITableViewCell? in
            guard let self = self else { return nil }

            switch item {
            case .author(let author):
                return self.authorCell(for: author, in: tableView, at: indexPath)
            case .loadMore:
                return self.loadMoreCell(at: indexPath, in: tableView)
            case .item(let item):
                let cell = tableView.dequeueCell(ofType: ItemTableViewCell.self, for: indexPath)
                cell.layer.shouldRasterize = true
                cell.layer.rasterizationScale = UIScreen.main.scale
                self.cellConfigurator.configure(cell,
                                                forDisplaying: item)
                return cell
            }
        })
    }

    @objc private func load() {
        tableView.refreshControl?.endRefreshing()
        viewModel.load()
    }

    private func applySnapshot() {
        viewModel.applicableSnapshot { [weak self] snapshot in
            guard let self = self else { return }
            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
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

        if let splitViewController = splitViewController as? VerticalTabsSplitViewController {
            extendedLayoutIncludesOpaqueBars = splitViewController.shouldIncludeBarInExtendedLayout
        }

        #if targetEnvironment(macCatalyst)
        if let navigationController = navigationController {
            navigationController.navigationBar.isHidden = navigationController.viewControllers.count > 1 ? false : true
        }
        #endif
    }

    private func showLoginOverlay() {
        addChild(loginOverlayHostingViewController)
        loginOverlayHostingViewController.view.frame = view.bounds
        view.addSubview(loginOverlayHostingViewController.view)
        loginOverlayHostingViewController.didMove(toParent: self)
    }

    private func hideLoginOverlay() {
        loginOverlayHostingViewController.willMove(toParent: nil)
        loginOverlayHostingViewController.view.removeFromSuperview()
        loginOverlayHostingViewController.removeFromParent()
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch viewModel.viewType(forRow: indexPath.row) {
        case .author, .loadMore:
            return
        case .item(let item):
            if isLoading == false {
                viewModel.set(lastReadRow: tableView.indexPathsForVisibleRows!.first!.row)
            }

            rowHeightEstimate[item.id] = cell.bounds.size.height

            updateUnread()

            if let cell = cell as? ItemTableViewCell {
                cell.setActionMenu(editActionsConfigurator.menu(cell: cell,
                                                                     indexPath: indexPath,
                                                                     inConversation: viewModel.inConversation))
            }
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

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return editActionsConfigurator.swipeActions(indexPath: indexPath,
                                                    direction: .leading,
                                                    inConversation: viewModel.inConversation)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return editActionsConfigurator.swipeActions(indexPath: indexPath,
                                                    direction: .trailing,
                                                    inConversation: viewModel.inConversation)
    }

    private func authorCell(for author: Author,
                            in tableView: UITableView,
                            at indexPath: IndexPath) -> ProfileTableViewCell {
        let cell = tableView.dequeueCell(ofType: ProfileTableViewCell.self, for: indexPath)
        profileViewConfigurator.configure(cell, using: author)
        return cell
    }

    private func loadMoreCell(at indexPath: IndexPath, in tableView: UITableView) -> LoadMoreTableViewCell {
        let cell = tableView.dequeueCell(ofType: LoadMoreTableViewCell.self, for: indexPath)
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

        unreadView.setCount(count)

        if count == 0 {
            unreadView.isHidden = true
        } else {
            unreadView.isHidden = false
        }
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return editActionsConfigurator.contextMenu(tableView: tableView,
                                                   indexPath: indexPath,
                                                   inConversation: viewModel.inConversation)
    }
}

extension ListViewController: ScrollToTop {
    func scrollToTop() {
        tableView.scroll(action: .top)
    }
}

extension ListViewController {
    func setupMainMenuNotification() {
        notificationCenter.addObserver(self,
                                       selector: #selector(refreshFromCommand),
                                       name: .mainMenuRefresh,
                                       object: nil)
    }

    override var keyCommands: [UIKeyCommand]? {
        let refreshCommand = UIKeyCommand(input: "r",
                                          modifierFlags: .command,
                                          action: #selector(refreshFromCommand))
        refreshCommand.discoverabilityTitle = "Refresh"

        let scrollUpCommand = UIKeyCommand(input: UIKeyCommand.inputUpArrow,
                                           modifierFlags: .command,
                                           action: #selector(scrollUpFromCommand))
        refreshCommand.discoverabilityTitle = "Scroll up"

        let scrollDownCommand = UIKeyCommand(input: UIKeyCommand.inputDownArrow,
                                             modifierFlags: .command,
                                             action: #selector(scrollDownFromCommand))
        scrollDownCommand.discoverabilityTitle = "Scroll down"

        let scrollToTopCommand = UIKeyCommand(input: UIKeyCommand.inputUpArrow,
                                              modifierFlags: [.shift, .command],
                                              action: #selector(scrollToTopFromCommand))
        scrollToTopCommand.discoverabilityTitle = "Scroll to top"

        let scrollToBottomCommand = UIKeyCommand(input: UIKeyCommand.inputDownArrow,
                                                 modifierFlags: [.shift, .command],
                                                 action: #selector(scrollToBottomFromCommand))
        scrollToBottomCommand.discoverabilityTitle = "Scroll to bottom"

        addKeyCommand(scrollUpCommand)

        return [refreshCommand, scrollUpCommand, scrollDownCommand, scrollToTopCommand, scrollToBottomCommand]
    }

    @objc private func refreshFromCommand() {
        guard isViewLoaded else { return }
        viewModel.load()
    }

    @objc private func scrollUpFromCommand() {
        tableView.scroll(action: .up)
    }

    @objc private func scrollDownFromCommand() {
        tableView.scroll(action: .down)
    }

    @objc private func scrollToTopFromCommand() {
        tableView.scroll(action: .top)
    }

    @objc private func scrollToBottomFromCommand() {
        tableView.scroll(action: .bottom)
    }

    private func showLoadingSpinnerIfNeeded() {
        if tableView.refreshControl?.isRefreshing == true {
            return
        }

        if navigationItem.rightBarButtonItems == nil {
            navigationItem.rightBarButtonItems = []
        }

        loadingSpinner.startAnimating()
        navigationItem.rightBarButtonItems?.append(loadingBarButtonItem)
    }

    private func hideLoadingSpinner() {
        guard let indexOfLoadingItem = navigationItem.rightBarButtonItems?.firstIndex(of: loadingBarButtonItem) else {
            return
        }

        loadingSpinner.stopAnimating()
        navigationItem.rightBarButtonItems?.remove(at: indexOfLoadingItem)
    }
}

private final class EditableTableViewDiffableDataSource: UITableViewDiffableDataSource<ListViewModel.Section, ListViewModel.ViewType> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

private final class UnreadView: UIView {
    enum Constants {
        static let mainViewLeading: CGFloat = 12.0

        static let labelPadding: CGFloat = 10.0

        static let cornerRadius: CGFloat = 4.0
        static let height: CGFloat = 24.0
    }

    private let unreadLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 12.0)

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(unreadLabel)

        NSLayoutConstraint.activate([
            unreadLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.labelPadding),
            unreadLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.labelPadding),
            unreadLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.cornerRadius),
            unreadLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: Constants.height)
        ])

        backgroundColor = Color.accent
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        layer.cornerRadius = Constants.cornerRadius
    }

    func setCount(_ count: Int) {
        unreadLabel.text = String(count)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
