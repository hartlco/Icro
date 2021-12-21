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
    private let imageUploadService = MicropubRequestController()
    private let userSettings: UserSettings
    private let client: Client

    @Published var text = "" {
        didSet {
            composeKeyboardInputViewModel.update(
                for: text,
                   numberOfImages: images.count,
                   imageState: imageState,
                   hidesImageButton: !imageUploadEnabled
            )
        }
    }
    @Published var replyItem: Item?
    @Published private(set) var images = [Image]()
    @Published var uploading = false

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
                   hidesImageButton: !imageUploadEnabled
            )
        }
    }

    public init(mode: Mode,
                userSettings: UserSettings = .shared,
                client: Client = URLSession.shared) {
        self.mode = mode
        self.userSettings = userSettings
        self.client = client
        self.composeKeyboardInputViewModel = .init()

        switch mode {
        case .reply(let item):
            self.replyItem = item
        case .post, .shareURL, .shareImage, .shareText:
            self.replyItem = nil
        }

        self.text = startText
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

    public var imageUploadEnabled: Bool {
        return userSettings.wordpressInfo == nil
    }

    @MainActor
    public func post() async throws {
        uploading = true
        composeKeyboardInputViewModel.postButtonEnabled = false

        let string = postWithImages(string: text)

        switch mode {
        case .post, .shareURL, .shareImage, .shareText:
            if userSettings.wordpressInfo != nil {
                try await postXMLRPC(string: string)
            } else if let info = userSettings.micropubInfo {
                try await MicropubRequestController().post(endpoint: .custom(info: info), message: string)
            } else {
                try await MicropubRequestController().post(endpoint: .micropub, message: string)
            }
        case .reply(let item):
            try await reply(item: item, string: string)
        }

        composeKeyboardInputViewModel.postButtonEnabled = true
        uploading = false
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

        let endpoint: MicropubEndpoint
        if let info = userSettings.micropubInfo {
            endpoint = .custom(info: info)
        } else {
            endpoint = .micropub
        }

        imageUploadService.uploadImages(endpoint: endpoint, image: image, uploadProgress: { [weak self] progress in
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

    private func postXMLRPC(string: String) async throws {
        guard let info = userSettings.wordpressInfo,
        let url = URL(string: info.urlString) else {
            throw NetworkingError.wordPressURLError
        }

        let postingURL = url.appendingPathComponent("xmlrpc.php")

        let params: [Any] = [1, info.username, info.password, ["post_content": string, "post_status": "publish"]]
        var request = URLRequest(url: postingURL)
        request.httpMethod = "POST"
        let encoder = WPXMLRPCEncoder(method: "wp.newPost", andParameters: params)
        request.httpBody = try? encoder.dataEncoded()

        try await _ = client.data(for: request, delegate: nil)
    }

    private func reply(item: Item, string: String) async throws {
        try await _ = client.load(resource: item.reply(with: string))
    }
}
