//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Foundation
import Settings
import Client
import UIKit

// swiftlint:disable type_body_length
public class ListViewModel: NSObject {
    public enum ItemActionBarChangeEvent {
        case show(indexPath: IndexPath)
        case hide(indexPath: IndexPath)
    }

    public enum Section {
        case main
    }

    public enum ListType: Equatable {
        case timeline
        case photos
        case mentions
        case favorites
        case discover
        case discoverCollection(category: DiscoveryCategory)
        case user(user: Author)
        case username(username: String)
        case conversation(item: Item)
    }

    public enum ViewType: Hashable {
        case author(author: Author)
        case item(item: Item)
        case loadMore(index: Int)
    }

    private var items = [Item]() {
        didSet {
            updateViewTypes()
        }
    }

    private var loadedAuthor: Author?
    private let type: ListType
    private let userSettings: UserSettings
    private let discoveryMananger: DiscoveryCategoryStore
    private let client: Client

    private var didScrollToTop = true
    private var blacklistChangedObserver: Any?

    public var didStartLoading: () -> Void = { }
    public var didFinishLoading: (Bool) -> Void = { _ in }
    public var didFinishWithError: (Error) -> Void = { _ in }

    private var visibleActionBarIndexPath: IndexPath?

    private var isLoading = false

    private lazy var showLoadMore: Bool = {
        return supportedLodMoreTypes
    }()

    private lazy var supportedLodMoreTypes: Bool = {
        switch type {
        case .mentions, .timeline, .favorites:
            return true
        default:
            return false
        }
    }()

    private var showLoadMoreInBetween = 0

    public init(type: ListType,
                userSettings: UserSettings = .shared,
                discoveryMananger: DiscoveryCategoryStore = DiscoveryCategoryStore(),
                client: Client = URLSession.shared) {
        self.type = type
        self.userSettings = userSettings
        self.discoveryMananger = discoveryMananger
        self.client = client
        super.init()

        blacklistChangedObserver = NotificationCenter.default.addObserver(forName: .blackListChanged,
                                                                          object: nil,
                                                                          queue: nil) { [weak self] _ in
            Item.deleteAllCached()
            self?.userSettings.lastread_timeline = nil
            self?.didScrollToTop = true
            self?.items = []
            self?.load()
        }
    }

    deinit {
        if let observer = blacklistChangedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    @objc public func loadFromCache() {
        guard !isLoading else { return }
        applyCache()
    }

    @objc public func load() {
        guard !isLoading, !showsLoginView else { return }

        didStartLoading()
        isLoading = true
        applyCache()

        Task {
            do {
                let value = try await client.load(resource: type.resource)
                self.isLoading = false

                // TODO: Use mainActor here
                DispatchQueue.main.async {
                    self.updateShowLoadMoreInBetweenAfterLoadMore(loadedNewItems: value.items)
                    self.loadedAuthor = value.author ?? self.loadedAuthor
                    self.insertNewItems(newItems: value.items)
                    self.updateUnreadItems()
                    self.didFinishLoading(false)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.didFinishWithError(error)
                }
            }
        }
    }

    public var inConversation: Bool {
        switch type {
        case .conversation:
            return true
        default:
            return false
        }
    }

    public func loadMore(afterItemAtIndex index: Int) {
        guard !isLoading else { return }

        guard index <= items.count,
        case .item(let lastItem) = viewTypes[index] else { return }

        if items.count > index + 1 {
            let nextItem = items[index + 1]
            userSettings.lastread_timeline = nextItem.id
        }
        let isLoadMoreInTheEnd = index == items.count - 1

        didStartLoading()
        isLoading = true
        client.load(resource: Item.resourceBefore(oldResource: type.resource, item: lastItem)) { [weak self] itemResponse in
            guard let self = self else { return }
            self.isLoading = false

            switch itemResponse {
            case .failure(let error):
                self.didFinishWithError(error)
            case .success(let value):
                if isLoadMoreInTheEnd {
                    self.updateShowLoadMore(loadedNewItems: value.items)
                } else {
                    self.updateShowLoadMoreInBetweenAfterLoadMore(loadedNewItems: value.items)
                }
                self.insertNewItems(newItems: value.items)
                self.updateUnreadItems()
                self.didFinishLoading(false)
            }
        }
    }

    public func applicableSnapshot(snapshotBlock: ((NSDiffableDataSourceSnapshot<Section, ListViewModel.ViewType>) -> Void)) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ListViewModel.ViewType>()
        snapshot.appendSections([.main  ])
        snapshot.appendItems(viewTypes)
        let lastReadItem = userSettings.lastread_timeline
        snapshotBlock(snapshot)
        userSettings.lastread_timeline = lastReadItem
    }

    public var shouldLoad: Bool {
        return items.count == 0
    }

    public func numberOfItems() -> Int {
        return viewTypes.count
    }

    public func viewType(forRow row: Int) -> ViewType {
        return viewTypes[row]
    }

    public var shouldShowProfileHeader: Bool {
        switch type {
        case .user, .username:
            return true
        default:
            return false
        }
    }

    public var author: Author? {
        switch type {
        case .user(let user):
            return loadedAuthor ?? user
        case .username:
            return loadedAuthor ?? items.first?.author
        default:
            return nil
        }
    }

    public var title: String {
        return type.title
    }

    public var icon: XImage? {
        return type.image
    }

    public func faveButtonTitle(for item: Item) -> String {
        return item.isFavorite ?
            NSLocalizedString("LISTVIEWMODEL_UNFAVEBUTTON_TITLE", comment: "") :
            NSLocalizedString("LISTVIEWMODEL_FAVEBUTTON_TITLE", comment: "")
    }

    public func toggleFave(for item: Item) {
        didStartLoading()
        client.load(resource: item.toggleFave()) { [weak self] _ in
            self?.saveCache()
            self?.didFinishLoading(false)
        }

        switch type {
        case .favorites:
            if item.isFavorite, let index = items.firstIndex(of: item) {
                items.remove(at: index)
                didFinishLoading(false)
            }
        default:
            item.isFavorite = !item.isFavorite
        }
    }

    public func index(for item: Item) -> Int? {
        return items.firstIndex(of: item)
    }

    public func toggleFollowForLoadedAuthor() {
        guard let author = author,
        let following = author.isFollowing else { return }
        let resource = following ? author.unfollowResource() : author.followResource()

        didStartLoading()
        client.load(resource: resource) { [weak self] _ in
            let newAuthor = Author(name: author.name,
                                   url: author.url,
                                   avatar: author.avatar,
                                   username: author.username,
                                   bio: author.bio,
                                   followingCount: author.followingCount,
                                   isFollowing: !following,
                                   isYou: author.isYou)
            self?.loadedAuthor = newAuthor
            self?.updateViewTypes()
            self?.didFinishLoading(false)
        }
    }

    public var numberOfUnreadItems: Int? {
        switch type {
        case .timeline:
            return items.firstIndex(where: { [weak self] item in
                return item.id == self?.userSettings.lastread_timeline
            })
        default:
            return nil
        }
    }

    public func set(lastReadRow: Int) {
        switch type {
        case .timeline:
            if let oldReadPosition = numberOfUnreadItems,
                oldReadPosition < lastReadRow {
                return
            }

            userSettings.lastread_timeline = items[lastReadRow].id
        default:
            return
        }
    }

    public func resetScrollPosition() {
        switch type {
        case .timeline:
            userSettings.lastread_timeline = items[0].id
        default:
            return
        }
    }

    public func resetContent() {
        for item in items {
            item.resetContent()
        }
    }

    public var showsDiscoverySections: Bool {
        switch type {
        case .discover where !discoveryMananger.categories.isEmpty:
            return true
        default:
            return false
        }
    }

    public var discoveryCategories: [DiscoveryCategory] {
        return discoveryMananger.categories
    }

    public let discoverySubtitle = NSLocalizedString("LISTVIEWMODEL_DISCOVER_SUBTITLE", comment: "")

    public var showsLoginView: Bool {
        switch type {
        case .discover, .discoverCollection, .user:
            return false
        default:
            return !userSettings.loggedIn
        }
    }

    public var barButtonEnabled: Bool {
        return userSettings.loggedIn
    }

    // MARK: - Private

    private func index(for identifier: String) -> Int? {
        for (index, item) in items.enumerated() {
            // swiftlint:disable for_where
            if item.id == identifier {
                return index
            }
        }

        return nil
    }

    private func applyCache() {
        switch type {
        case .timeline:
            Item.allCached { cached in
                self.items = cached?.items ?? []
                self.loadedAuthor = cached?.author
                self.updateUnreadItems()
                self.didFinishLoading(true)
            }
        default:
            return
        }
    }

    private func saveCache() {
        switch type {
        case .timeline:
            Item.saveAllCached(itemResponse: ItemResponse(author: loadedAuthor, items: items))
        default:
            return
        }
    }

    private func updateUnreadItems() {
        guard self.items.count > 0 else { return }

        didScrollToTop = userSettings.lastread_timeline == items[0].id
    }

    private func appendMoreLoadedItem(moreItems: [Item], after item: Item) {
        guard let firstMoreItem = moreItems.first,
            !items.contains(firstMoreItem) else { return }

        guard let index = items.firstIndex(where: { indexItem in
            indexItem == item
        }) else { return }

        items.insert(contentsOf: moreItems, at: index + 1)
    }

    private func updateShowLoadMore(loadedNewItems: [Item] = []) {
        if items.count == 0 || loadedNewItems.count == 0 {
            showLoadMore = false
            return
        }

        if let firstNewItem = loadedNewItems.first,
            items.contains(firstNewItem) {
            showLoadMore = false
            return
        }

        showLoadMore = true
    }

    private func updateShowLoadMoreInBetweenAfterLoadMore(loadedNewItems: [Item] = []) {
        if items.count == 0 || loadedNewItems.count == 0 {
            showLoadMoreInBetween = 0
            return
        }

        for loadedItem in loadedNewItems {
            if items.contains(loadedItem) {
                showLoadMoreInBetween = 0
                return
            }
        }

        showLoadMoreInBetween += loadedNewItems.count
    }

    private var viewTypes: [ViewType] = []

    private func updateViewTypes() {
        var viewTypes = [ViewType]()
        if shouldShowProfileHeader, let author = author {
            viewTypes.append(.author(author: author))
        }

        viewTypes.append(contentsOf: items.map({
            return ViewType.item(item: $0)
        }))

        if showLoadMore, items.count != 0, supportedLodMoreTypes {
            viewTypes.append(.loadMore(index: items.count - 1))
        }

        if showLoadMoreInBetween != 0, supportedLodMoreTypes, !viewTypes.isEmpty {
            viewTypes.insert(.loadMore(index: showLoadMoreInBetween), at: showLoadMoreInBetween)
        }

        self.viewTypes = viewTypes

        if case .conversation = type {
            self.viewTypes = self.viewTypes.reversed()
        }
    }
}

extension ListViewModel {
    func insertNewItems(newItems: [Item]) {
        let allItemsSet = Set<Item>(newItems + items)
        let allItems = Array(allItemsSet).sorted(by: {
            return ($0.date_published >= $1.date_published)
        })

        items = allItems
        saveCache()
    }
}
