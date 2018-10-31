//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import wpxmlrpc

public enum ImageState {
    case idle
    case uploading(progress: Float)
}

public final class ComposeViewModel {
    public struct Image {
        public init(title: String, link: URL) {
            self.title = title
            self.link = link
        }

        public let title: String
        public let link: URL
    }

    public enum Mode {
        case post
        case reply(item: Item)
    }

    private let mode: Mode
    private var images = [Image]()
    private let imageUploadService = MicropubRequestController()
    private let userSettings: UserSettings

    private(set) public var imageState = ImageState.idle {
        didSet {
            didChangeImageState?(imageState)
        }
    }

    public var didChangeImageState: ((ImageState) -> Void)?

    public var didUpdateImages: (() -> Void)?

    public init(mode: Mode,
                userSettings: UserSettings = .shared) {
        self.mode = mode
        self.userSettings = userSettings
    }

    public var startText: String {
        switch mode {
        case .post:
            return ""
        case .reply(let item):
            return "@" + (item.author.username ?? "") + " "
        }
    }

    public var imageUploadEnabled: Bool {
        return userSettings.wordpressInfo == nil
    }

    public func post(string: String, completion: @escaping (Error?) -> Void) {
        let string = postWithImages(string: string)

        switch mode {
        case .post:
            if userSettings.wordpressInfo != nil {
                postXMLRPC(string: string, completion: completion)
            } else if let info = userSettings.micropubInfo {
                MicropubRequestController().post(endpoint: .custom(info: info), message: string, completion: completion)
            } else {
                MicropubRequestController().post(endpoint: .micropub, message: string, completion: completion)
            }
        case .reply(let item):
            reply(item: item, string: string, completion: completion)
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
        didUpdateImages?()
    }

    public func removeImage(at index: Int) {
        images.remove(at: index)
        didUpdateImages?()
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

    // MARK: - Private

    private func postWithImages(string: String) -> String {
        guard images.count > 0 else { return string }

        let imagesStrings: [String] = images.map { image in
            return "![\(image.title)](\(image.link))"
        }

        return string + "\n" + imagesStrings.joined(separator: "\n")
    }

    private func postXMLRPC(string: String, completion: @escaping (Error?) -> Void) {
        guard let info = userSettings.wordpressInfo,
        let url = URL(string: info.urlString) else {
            completion(NetworkingError.wordPressURLError)
            return
        }

        let postingURL = url.appendingPathComponent("xmlrpc.php")

        let params: [Any] = [1, info.username, info.password, ["post_content": string, "post_status": "publish"]]
        var request = URLRequest(url: postingURL)
        request.httpMethod = "POST"
        let encoder = WPXMLRPCEncoder(method: "wp.newPost", andParameters: params)
        request.httpBody = try? encoder.dataEncoded()
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }.resume()
    }

    public func postHostedBlog(string: String, completion: @escaping () -> Void) {
        Webservice().load(resource: Item.post(text: string), bearer: true) { _ in
            completion()
        }
    }

    public func reply(item: Item, string: String, completion: @escaping (Error?) -> Void) {
        Webservice().load(resource: item.reply(with: string)) { response in
            switch response {
            case .error(let error):
                completion(error)
            case .result:
                completion(nil)
            }
        }
    }

    public var replyItem: Item? {
        switch mode {
        case .reply(let item):
            return item
        case .post:
            return nil
        }
    }
}
