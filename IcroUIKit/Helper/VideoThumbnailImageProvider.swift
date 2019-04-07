//
//  Created by martin on 07.04.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import Kingfisher
import AVFoundation

public struct VideoThumbnailImageProvider: ImageDataProvider {
    enum ProviderError: Error {
        case convertingFailed(CGImage)
    }

    let url: URL

    private let size = CGSize(width: 500, height: 500)

    public init(url: URL) {
        self.url = url
    }

    public var cacheKey: String { return "\(url.absoluteString)_\(size)" }

    public func data(handler: @escaping (Kingfisher.Result<Data, Error>) -> Void) {

        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: self.url)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            assetImgGenerate.maximumSize = self.size
            let time = CMTime(seconds: 1, preferredTimescale: 10)
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                if let data = UIImage(cgImage: img).jpegData(compressionQuality: 0.8) {
                    handler(.success(data))
                } else {
                    handler(.failure(ProviderError.convertingFailed(img)))
                }
            } catch {
                handler(.failure(error))
            }
        }
    }
}
