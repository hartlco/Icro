//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Foundation

// swiftlint:disable type_body_length
public class ListViewModel: NSObject {
    public enum ListType {
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

    public enum ViewType {
        case author(author: Author)
        case item(item: Item)
        case loadMore
    }

    private var items = [Item]() {
        didSet {
            updateViewTypes()
        }
    }

    private var loadedAuthor: Author?
    private let type: ListType
    private let userSettings: UserSettings
    private let discoveryMananger: DiscoveryCategoryManager

    private var unreadItems = Set<Int>()
    private var blacklistChangedObserver: Any?

    public var didStartLoading: () -> Void = { }
    public var didFinishLoading: (Bool) -> Void = { _ in }
    public var didFinishWithError: (Error) -> Void = { _ in }

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
                discoveryMananger: DiscoveryCategoryManager = .shared) {
        self.type = type
        self.userSettings = userSettings
        self.discoveryMananger = discoveryMananger
        super.init()

        blacklistChangedObserver = NotificationCenter.default.addObserver(forName: .blackListChanged,
                                                                          object: nil,
                                                                          queue: nil) { [weak self] _ in
            Item.deleteAllCached()
            self?.userSettings.lastread_timeline = nil
            self?.unreadItems = Set<Int>()
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
        guard !isLoading else { return }

        didStartLoading()
        isLoading = true
        applyCache()
        Webservice().load(resource: type.resource) { [weak self] itemResponse in
            guard let self = self else { return }

            self.isLoading = false
            switch itemResponse {
            case .error(let error):
                self.didFinishWithError(error)
            case .result(let value):
                self.updateShowLoadMoreInBetweenAfterLoadMore(loadedNewItems: value.items)
                self.insertNewItems(newItems: value.items)
                self.loadedAuthor = value.author ?? self.loadedAuthor
                self.updateUnreadItems()
                self.didFinishLoading(false)
            }
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
        Webservice().load(resource: Item.resourceBefore(oldResource: type.resource, item: lastItem)) { [weak self] itemResponse in
            guard let self = self else { return }
            self.isLoading = false

            switch itemResponse {
            case .error(let error):
                self.didFinishWithError(error)
            case .result(let value):
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
        Webservice().load(resource: item.toggleFave()) { [weak self] _ in
            self?.saveCache()
            self?.didFinishLoading(false)
        }

        switch type {
        case .favorites:
            if item.isFavorite, let index = items.index(of: item) {
                items.remove(at: index)
                didFinishLoading(false)
            }
        default:
            item.isFavorite = !item.isFavorite
        }
    }

    public func index(for item: Item) -> Int? {
        return items.index(of: item)
    }

    public func toggleFollowForLoadedAuthor() {
        guard let author = loadedAuthor,
        let following = author.isFollowing else { return }
        let resource = following ? author.unfollowResource() : author.followResource()

        didStartLoading()
        Webservice().load(resource: resource) { [weak self] _ in
            let newAuthor = Author(name: author.name,
                                   url: author.url,
                                   avatar: author.avatar,
                                   username: author.username,
                                   bio: author.bio,
                                   followingCount: author.followingCount,
                                   isFollowing: !following,
                                   isYou: author.isYou)
            self?.loadedAuthor = newAuthor
            self?.didFinishLoading(false)
        }
    }

    public var lastReadIndex: Int? {
        guard items.count > 0 else { return nil }

        switch type {
        case .timeline:
            guard let lastReadID = userSettings.lastread_timeline,
                let index = index(for: lastReadID) else {
                    userSettings.lastread_timeline = items.first?.id
                    return 0
            }
            return index
        default:
            return nil
        }
    }

    public var numberOfUnreadItems: Int? {
        guard unreadItems.count > 0 else { return nil }

        switch type {
        case .timeline:
            return unreadItems.count
        default:
            return nil
        }
    }

    public func set(lastReadRow: Int) {
        guard let removedIndex = unreadItems.remove(lastReadRow) else { return }
        let item = items[removedIndex]

        switch type {
        case .timeline:
            userSettings.lastread_timeline = item.id
        default:
            return
        }
    }

    public func resetScrollPosition() {
        guard let removedIndex = unreadItems.remove(0) else { return }
        let item = items[removedIndex]
        unreadItems = Set<Int>()

        switch type {
        case .timeline:
            userSettings.lastread_timeline = item.id
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

        let lastReadIndex = self.lastReadIndex ?? (self.items.count - 1)
        for index in 0..<lastReadIndex {
            self.unreadItems.insert(index)
        }
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
            viewTypes.append(.loadMore)
        }

        if showLoadMoreInBetween != 0, supportedLodMoreTypes {
            viewTypes.insert(.loadMore, at: showLoadMoreInBetween)
        }

        self.viewTypes = viewTypes
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
