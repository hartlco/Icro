//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import Settings
import Client

public enum ImageState {
    case idle
    case uploading(progress: Float)
}

struct MentionQuery: Equatable {
    let range: NSRange
    let searchText: String

    private static let prefixPattern = try! NSRegularExpression(
        pattern: "(?<![\\p{L}\\p{N}_@/])@([\\p{L}\\p{N}_.-]*)\\z"
    )
    private static let suffixPattern = try! NSRegularExpression(pattern: "^[\\p{L}\\p{N}_.-]*")

    static func active(in text: String, selection: NSRange) -> MentionQuery? {
        let nsText = text as NSString
        guard selection.length == 0, selection.location <= nsText.length else { return nil }

        let prefix = nsText.substring(to: selection.location)
        let prefixRange = NSRange(location: 0, length: (prefix as NSString).length)
        guard let match = prefixPattern.firstMatch(in: prefix, range: prefixRange) else { return nil }

        let suffix = nsText.substring(from: selection.location)
        let suffixMatch = suffixPattern.firstMatch(
            in: suffix,
            range: NSRange(location: 0, length: (suffix as NSString).length)
        )
        return MentionQuery(
            range: NSRange(location: match.range.location,
                           length: match.range.length + (suffixMatch?.range.length ?? 0)),
            searchText: (prefix as NSString).substring(with: match.range(at: 1))
        )
    }

    func completing(with username: String, in text: String) -> (text: String, cursor: Int) {
        let nsText = text as NSString
        let alreadySeparated = NSMaxRange(range) < nsText.length
            && nsText.substring(from: NSMaxRange(range)).first?.isWhitespace == true
        let replacement = "@\(username)" + (alreadySeparated ? "" : " ")
        return (nsText.replacingCharacters(in: range, with: replacement),
                range.location + (replacement as NSString).length)
    }
}

public final class ComposeViewModel: ObservableObject {
    public struct Image: Identifiable {
        public init(title: String, link: URL) {
            self.title = title
            self.link = link
        }

        public let title: String
        public let link: URL

        public var id: String {
            return link.absoluteString
        }
    }

    public enum Mode {
        case post
        case shareURL(url: URL, title: String)
        case shareImage(image: Image)
        case shareText(text: String)
        case reply(item: Item)
    }

    private let mode: Mode
    private let imageUploadService: MicropubRequestController
    private let userSettings: UserSettings
    private let client: Client

    @Published var text = "" {
        didSet {
            composeKeyboardInputViewModel.update(
                for: text,
                   numberOfImages: images.count,
                   imageState: imageState,
                   hidesImageButton: false
            )
        }
    }
    @Published var replyItem: Item?
    @Published private(set) var images = [Image]()
    @Published var uploading = false
    @Published public private(set) var destinations = [MicroBlogDestination]()
    @Published public private(set) var selectedDestination: MicroBlogDestination?
    @Published public private(set) var availableCategories = [String]()
    @Published public private(set) var selectedCategories = Set<String>()
    @Published public private(set) var publishingOptionsFailed = false
    @Published public var isDraft = false
    @Published private(set) var followingAuthors = [Author]()
    @Published private(set) var replyAuthors = [Author]()
    @Published private(set) var mentionsLoading = false

    private var didLoadFollowing = false
    private var didLoadReplyThread = false

    @Published var imagePickerActive = false
    @Published var pickedImage: Data? {
        didSet {
            imagePickerActive = false

            guard let data = pickedImage, let image = XImage(data: data) else { return }

            upload(image: image)
        }
    }

    let composeKeyboardInputViewModel: ComposeKeyboardInputViewModel

    private(set) public var imageState = ImageState.idle {
        didSet {
            composeKeyboardInputViewModel.update(
                for: text,
                   numberOfImages: images.count,
                   imageState: imageState,
                   hidesImageButton: false
            )
        }
    }

    public init(mode: Mode,
                userSettings: UserSettings = .shared,
                client: Client = URLSession.shared) {
        self.mode = mode
        self.userSettings = userSettings
        self.client = client
        self.imageUploadService = MicropubRequestController(client: client)
        self.composeKeyboardInputViewModel = .init()
        if let preferred = userSettings.preferredBlogDestination,
           let uid = URL(string: preferred), uid.scheme == "https" {
            let displayName = uid.host ?? preferred
            self.selectedDestination = MicroBlogDestination(uid: uid,
                                                             name: displayName,
                                                             title: displayName)
        }

        switch mode {
        case .reply(let item):
            self.replyItem = item
            self.replyAuthors = [item.author]
        case .post, .shareURL, .shareImage, .shareText:
            self.replyItem = nil
        }

        self.text = startText
        composeKeyboardInputViewModel.update(
            for: text,
            numberOfImages: images.count,
            imageState: imageState,
            hidesImageButton: false
        )
    }

    public var showKeyboardOnAppear: Bool {
        switch mode {
        case .reply, .post:
            return true
        case .shareImage, .shareText, .shareURL:
            return false
        }
    }

    private var startText: String {
        switch mode {
        case .post:
            return ""
        case .reply(let item):
            return "@" + (item.author.username ?? "") + " "
        case .shareURL(let url, let title):
            return linkText(url: url, title: title)
        case .shareImage(let image):
            images.append(image)
            return ""
        case .shareText(let text):
            return text
        }
    }

    public var isReply: Bool {
        if case .reply = mode { return true }
        return false
    }

    @MainActor
    func loadFollowingCandidates() async {
        guard !didLoadFollowing, userSettings.loggedIn else { return }
        didLoadFollowing = true
        mentionsLoading = true
        defer { mentionsLoading = false }

        let username = userSettings.username
        let token = userSettings.token
        do {
            let authors = try await client.load(resource: Author.followingResource(username: username,
                                                                                     token: token))
            guard userSettings.username == username, userSettings.token == token else { return }
            followingAuthors = authors
        } catch {
            followingAuthors = []
        }
    }

    @MainActor
    func loadReplyThreadCandidates() async {
        guard !didLoadReplyThread, let replyItem else { return }
        didLoadReplyThread = true
        do {
            let response = try await client.load(resource: replyItem.conversation)
            replyAuthors = [replyItem.author] + response.items.reversed().map(\.author)
        } catch {
            replyAuthors = [replyItem.author]
        }
    }

    func mentionSuggestions(matching query: String) -> [Author] {
        let search = query.lowercased()
        let ownUsername = userSettings.username.lowercased()
        let candidates = replyAuthors + followingAuthors
        var seen = Set<String>()
        let matching = candidates.filter { author in
            guard let username = author.username, !username.isEmpty else { return false }
            let key = username.lowercased()
            guard key != ownUsername, seen.insert(key).inserted else { return false }
            return search.isEmpty || key.hasPrefix(search) || author.name.localizedStandardContains(query)
        }
        let byUsername = matching.filter { $0.username?.lowercased().hasPrefix(search) == true }
        let byName = matching.filter { $0.username?.lowercased().hasPrefix(search) != true }
        return Array((byUsername + byName).prefix(8))
    }

    @MainActor
    public func loadPublishingOptions() async {
        guard !isReply else { return }
        do {
            let configuration = try await client.load(resource: MicroBlogConfiguration.get(token: userSettings.token))
            destinations = configuration.destinations
            selectedDestination = destinations.first { $0.id == userSettings.preferredBlogDestination }
            publishingOptionsFailed = false
        } catch {
            publishingOptionsFailed = true
        }
        await loadCategories()
    }

    @MainActor
    public func selectDestination(_ destination: MicroBlogDestination?) async {
        selectedDestination = destination
        userSettings.preferredBlogDestination = destination?.id
        selectedCategories = []
        await loadCategories()
    }

    public func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    @MainActor
    private func loadCategories() async {
        do {
            let destination = selectedDestination?.uid
            let response = try await client.load(resource: MicroBlogCategories.get(token: userSettings.token,
                                                                                    destination: destination))
            guard selectedDestination?.uid == destination else { return }
            availableCategories = response.categories
            publishingOptionsFailed = false
        } catch {
            availableCategories = []
            publishingOptionsFailed = true
        }
    }

    @MainActor
    public func post() async throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !images.isEmpty else {
            throw NetworkingError.invalidInput
        }
        uploading = true
        composeKeyboardInputViewModel.postButtonEnabled = false
        defer {
            uploading = false
            composeKeyboardInputViewModel.update(for: text,
                                                 numberOfImages: images.count,
                                                 imageState: imageState,
                                                 hidesImageButton: false)
        }

        let string = postWithImages(string: text)

        switch mode {
        case .post, .shareURL, .shareImage, .shareText:
            try await imageUploadService.post(token: userSettings.token,
                                              message: string,
                                              destination: selectedDestination?.uid,
                                              categories: selectedCategories.sorted(),
                                              draft: isDraft)
        case .reply(let item):
            try await reply(item: item, string: string)
        }
    }

    public var numberOfImages: Int {
        return images.count
    }

    public func image(at index: Int) -> Image {
        return images[index]
    }

    public func insertImage(image: Image) {
        images.append(image)
    }

    public func linkText(url: URL, title: String) -> String {
        return "[\(title)](\(url))"
    }

    public func insertLink(url: URL, title: String?) {
        text += " [\(title ?? "")](\(url.absoluteString))"
    }

    public func removeImage(at index: Int) {
        guard images.count > index else {
            return
        }

        images.remove(at: index)
    }

    public func upload(image: XImage) {
        imageState = .uploading(progress: 0.0)

        imageUploadService.uploadImages(token: userSettings.token,
                                        destination: selectedDestination?.uid,
                                        image: image,
                                        uploadProgress: { [weak self] progress in
            self?.imageState = .uploading(progress: progress)
            }, completion: { [weak self] image, _ in
            self?.imageState = .idle

            if let image = image {
                self?.insertImage(image: image)
            }
        })
    }

    public func cancelImageUpload() {
        imageState = .idle
        imageUploadService.cancelImageUpload()
    }

    public func galleryDataSource(for index: Int) -> GalleryDataSource {
        return GalleryDataSource(index: index, media: images.map({
            return Media(url: $0.link, isVideo: false)
        }))
    }

    // MARK: - Private

    private func postWithImages(string: String) -> String {
        guard images.count > 0 else { return string }

        let imagesStrings: [String] = images.map { image in
            return "![\(image.title)](\(image.link))"
        }

        return string + "\n" + imagesStrings.joined(separator: "\n")
    }

    private func reply(item: Item, string: String) async throws {
        try await _ = client.load(resource: item.reply(with: string))
    }
}
