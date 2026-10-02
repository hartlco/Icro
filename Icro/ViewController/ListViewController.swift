//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import UIKit
import Style
import DropdownTitleView
import SwiftUI

final class ListViewController: UIViewController {
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.separatorColor = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.20, green: 0.21, blue: 0.23, alpha: 1)
                : UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1)
        }
        tableView.separatorInset = .zero
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(viewModel, action: #selector(ListViewModel.load), for: .valueChanged)
        tableView.registerClass(cellType: ItemTableViewCell.self)
        tableView.registerClass(cellType: HostingCell<ProfileCellView>.self)
        tableView.registerClass(cellType: LoadMoreTableViewCell.self)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension

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
    private var didRestoreUnreadPosition = false
    private var rowHeightEstimate = [String: CGFloat]()
    private let notificationCenter: NotificationCenter
    private let loadingSpinner = UIActivityIndicatorView(style: .medium)
    private let loadingBarButtonItem: UIBarButtonItem

    private let loginOverlayHostingViewController: UIHostingController<LoginOverlayView>
    private lazy var loadingPlaceholderHostingViewController = UIHostingController(
        rootView: LoadingSkeletonView(kind: .feed(profile: viewModel.shouldShowProfileHeader))
    )

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
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        unreadView.addTarget(self, action: #selector(showUnreadPosts), for: .touchUpInside)
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
            self.showLoadingPlaceholderIfNeeded()
            self.showLoadingSpinnerIfNeeded()
        }

        viewModel.didFinishLoading = { [weak self] cache in
            if cache == false {
                self?.hideLoadingSpinner()
                self?.tableView.refreshControl?.endRefreshing()
            }

            self?.applySnapshot()
            if cache == false || self?.viewModel.shouldLoad == false {
                self?.hideLoadingPlaceholder()
            }
            if let self = self, !self.didRestoreUnreadPosition {
                if let newIndex = self.viewModel.numberOfUnreadItems, newIndex != 0 {
                    self.updateUnread()
                    self.tableView.scrollToRow(at: IndexPath(row: newIndex, section: 0), at: .top, animated: false)
                    self.didRestoreUnreadPosition = true
                } else if !cache {
                    self.didRestoreUnreadPosition = true
                }
            }
            self?.isLoading = false
        }

        viewModel.didFinishWithError = { [weak self] error in
            self?.hideLoadingSpinner()
            self?.tableView.refreshControl?.endRefreshing()
            self?.isLoading = false
            self?.hideLoadingPlaceholder()
            self?.tableView.visibleCells.compactMap { $0 as? LoadMoreTableViewCell }.forEach { $0.showRetry() }
            self?.showError(error: error)
        }

        viewModel.didUpdateDiscoveryCategories = { [weak self] in
            self?.updateDiscoverySectionsIfNeeded()
        }

        setupNavigateBackShortcut(with: notificationCenter)

        // Hide empty cells
        tableView.tableFooterView = UIView(frame: .zero)

        let loadingView = loadingPlaceholderHostingViewController.view!
        addChild(loadingPlaceholderHostingViewController)
        loadingView.frame = view.bounds
        loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loadingView.isUserInteractionEnabled = false
        loadingView.isHidden = true
        view.addSubview(loadingView)
        loadingPlaceholderHostingViewController.didMove(toParent: self)
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
        showLoadingPlaceholderIfNeeded()

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingPlaceholderHostingViewController.view.frame = view.bounds
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
        guard titleView == nil else { return }

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
        itemNavigator.showDiscoveryCategories(categories: viewModel.discoveryCategories)
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
        hideLoadingPlaceholder()
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

    private func showLoadingPlaceholderIfNeeded() {
        let profileHeaderCount = viewModel.shouldShowProfileHeader && viewModel.author != nil ? 1 : 0
        let hasPosts = viewModel.numberOfItems() > profileHeaderCount
        let loadingView = loadingPlaceholderHostingViewController.view!
        loadingView.isHidden = hasPosts || viewModel.showsLoginView
        if !loadingView.isHidden {
            loadingView.frame = view.bounds
            view.bringSubviewToFront(loadingView)
        }
    }

    private func hideLoadingPlaceholder() {
        loadingPlaceholderHostingViewController.view.isHidden = true
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch viewModel.viewType(forRow: indexPath.row) {
        case .author:
            return
        case .loadMore:
            guard let cell = cell as? LoadMoreTableViewCell else { return }
            if viewModel.loadMore(afterItemAtIndex: indexPath.row - 1, automatically: true)
                || viewModel.isLoadingMore {
                cell.showLoading()
            } else if viewModel.shouldShowLoadMoreRetry {
                cell.showRetry()
            }
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
                            at indexPath: IndexPath) -> HostingCell<ProfileCellView> {
        let cell = tableView.dequeueCell(ofType: HostingCell<ProfileCellView>.self, for: indexPath)
        profileViewConfigurator.configure(cell, using: author, parentViewController: self)
        return cell
    }

    private func loadMoreCell(at indexPath: IndexPath, in tableView: UITableView) -> LoadMoreTableViewCell {
        let cell = tableView.dequeueCell(ofType: LoadMoreTableViewCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.didPressLoadMore = { [weak self] in
            guard let self = self else { return }
            self.viewModel.loadMore(afterItemAtIndex: indexPath.row - 1)
        }

        return cell
    }

    private func updateUnread() {
        guard let count = viewModel.numberOfUnreadItems else {
            unreadView.isHidden = true
            if navigationItem.titleView === unreadView { navigationItem.titleView = nil }
            return
        }

        unreadView.setCount(count)

        if count == 0 {
            unreadView.isHidden = true
            if navigationItem.titleView === unreadView { navigationItem.titleView = nil }
        } else {
            unreadView.isHidden = false
            if navigationItem.titleView !== unreadView { navigationItem.titleView = unreadView }
        }
    }

    @objc private func showUnreadPosts() {
        unreadView.isHidden = true
        if navigationItem.titleView === unreadView { navigationItem.titleView = nil }
        scrollToTop()
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

private final class UnreadView: UIControl {
    override var intrinsicContentSize: CGSize {
        CGSize(width: unreadLabel.intrinsicContentSize.width + 71, height: 48)
    }

    private let glassView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()

    private let arrowView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "arrow.up"))
        view.tintColor = Color.main
        view.contentMode = .scaleAspectFit
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()

    private let unreadLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityTraits = .button
        updateGlassTint()

        let stack = UIStackView(arrangedSubviews: [arrowView, unreadLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 7

        addSubview(glassView)
        glassView.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassView.topAnchor.constraint(equalTo: topAnchor),
            glassView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: glassView.contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: glassView.contentView.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: glassView.contentView.centerYAnchor),
            stack.topAnchor.constraint(greaterThanOrEqualTo: glassView.contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: glassView.contentView.bottomAnchor, constant: -8),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
    }

    func setCount(_ count: Int) {
        let key = count == 1 ? "TIMELINE_NEW_POST_SINGULAR" : "TIMELINE_NEW_POSTS_PLURAL"
        let format = NSLocalizedString(key, comment: "Unread timeline posts")
        let title = String.localizedStringWithFormat(format, count)
        unreadLabel.text = title
        accessibilityLabel = title
        invalidateIntrinsicContentSize()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateGlassTint()
    }

    private func updateGlassTint() {
        (glassView.effect as? UIGlassEffect)?.tintColor = tintColor.withAlphaComponent(0.35)
        arrowView.tintColor = .label
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
