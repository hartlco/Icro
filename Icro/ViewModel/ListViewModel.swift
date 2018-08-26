//
//  Created by Martin Hartl on 29/04/2017.
//  Copyright © 2017 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit

// swiftlint:disable type_body_length
class ListViewModel: NSObject {
    enum ListType {
        case timeline
        case photos
        case mentions
        case favorites
        case discover
        case user(user: Author)
        case username(username: String)
        case conversation(item: Item)

        var resource: Resource<ItemResponse> {
            switch self {
            case .timeline:
                return Item.all()
            case .photos:
                return Item.photos
            case .mentions:
                return Item.mentions
            case .favorites:
                return Item.favorites
            case .discover:
                return Item.discover
            case .user(let user):
                return Item.resource(forAuthor: user)
            case .conversation(let item):
                return item.conversation
            case .username(let username):
                return Item.usernamePostURL(for: username)
            }
        }

        var title: String {
            switch self {
            case .timeline:
                return NSLocalizedString("LISTVIEWMODEL_RESOURCETITLE_TIMELINE", comment: "")
            case .photos:
                return NSLocalizedString("LISTVIEWMODEL_RESOURCETITLE_PHOTOS", comment: "")
            case .mentions:
                return NSLocalizedString("LISTVIEWMODEL_RESOURCETITLE_MENTIONS", comment: "")
            case .favorites:
                return NSLocalizedString("LISTVIEWMODEL_RESOURCETITLE_FAVORITES", comment: "")
            case .discover:
                return NSLocalizedString("LISTVIEWMODEL_RESOURCETITLE_DISCOVER", comment: "")
            case .user(let user):
                return user.username ?? ""
            case .username(let username):
                return username
            case .conversation:
                return NSLocalizedString("LISTVIEWMODEL_RESOURCETITLE_CONVERSATION", comment: "")
            }
        }
    }

    enum ViewType {
        case author(author: Author)
        case item
    }

    private var items = [Item]()
    private var loadedAuthor: Author?
    private let type: ListType
    private let userSettings: UserSettings

    private var unreadItems = Set<Int>()
    private var blacklistChangedObserver: Any?

    var didStartLoading: () -> Void = { }
    var didFinishLoading: (Bool) -> Void = { _ in }
    var didFinishWithError: (Error) -> Void = { _ in }

    init(type: ListType,
         userSettings: UserSettings = .shared) {
        self.type = type
        self.userSettings = userSettings
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

    @objc dynamic func load() {
        didStartLoading()
        applyCache()
        Webservice().load(resource: type.resource) { itemResponse in
            switch itemResponse {
            case .error(let error):
                self.didFinishWithError(error)
            case .result(let value):
                self.items = value.items
                self.loadedAuthor = value.author ?? self.loadedAuthor
                self.updateUnreadItems()
                self.didFinishLoading(false)
            }
        }
    }

    var shouldLoad: Bool {
        return items.count == 0
    }

    func numberOfItems(in section: Int) -> Int {
        if shouldShowProfileHeader, section == 0, author != nil {
            return 1
        }

        return items.count
    }

    var numberOfSections: Int {
        if shouldShowProfileHeader, author != nil {
            return 2
        }

        return 1
    }

    func viewType(for section: Int, row: Int) -> ViewType {
        if shouldShowProfileHeader, section == 0, let author = author {
            return .author(author: author)
        }

        return .item
    }

    func item(for index: Int) -> Item {
        return items[index]
    }

    func firstItem() -> Item? {
        return items.first
    }

    var shouldShowProfileHeader: Bool {
        switch type {
        case .user, .username:
            return true
        default:
            return false
        }
    }

    var author: Author? {
        switch type {
        case .user(let user):
            return loadedAuthor ?? user
        case .username:
            return loadedAuthor ?? items.first?.author
        default:
            return nil
        }
    }

    var title: String {
        return type.title
    }

    func faveButtonTitle(for item: Item) -> String {
        return item.isFavorite ?
            NSLocalizedString("LISTVIEWMODEL_UNFAVEBUTTON_TITLE", comment: "") :
            NSLocalizedString("LISTVIEWMODEL_FAVEBUTTON_TITLE", comment: "")
    }

    func toggleFave(for item: Item) {
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

    func index(for item: Item) -> Int? {
        return items.index(of: item)
    }

    func toggleFollowForLoadedAuthor() {
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

    var lastReadIndex: Int? {
        guard items.count > 0 else { return nil }

        switch type {
        case .timeline:
            guard let lastReadID = userSettings.lastread_timeline,
                let index = index(for: lastReadID) else { return nil }
            return index
        default:
            return nil
        }
    }

    var numberOfUnreadItems: Int? {
        guard unreadItems.count > 0 else { return nil }

        switch type {
        case .timeline:
            return unreadItems.count
        default:
            return nil
        }
    }

    func set(lastReadRow: Int) {
        guard let removedIndex = unreadItems.remove(lastReadRow) else { return }
        let item = items[removedIndex]

        switch type {
        case .timeline:
            userSettings.lastread_timeline = item.id
        default:
            return
        }
    }

    func resetScrollPosition() {
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

    func resetContent() {
        for item in items {
            item.resetContent()
        }
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

        let lastReadIndex = self.lastReadIndex ?? (self.items.count - 1)
        for index in 0..<lastReadIndex {
            self.unreadItems.insert(index)
        }
    }
}
