//
//  Created by Martin Hartl on 30.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import Kingfisher

public struct NetworkImage: SwiftUI.View {
    // swiftlint:disable:next redundant_optional_initialization
    @State private var image: UIImage? = nil

    public let imageURL: URL?

    public var body: some SwiftUI.View {
        ZStack {
            Rectangle()
                .foregroundColor(backgroundColor)
            image.map { image in
                Image(uiImage: image)
                .resizable()
                .id(image)
            }
        }
        .onAppear(perform: loadImage)
    }

    private func loadImage() {
        guard let imageURL = imageURL, image == nil else { return }
        KingfisherManager.shared.retrieveImage(with: imageURL) { result in
            switch result {
            case .success(let imageResult):
                self.image = imageResult.image
            case .failure:
                break
            }
        }
    }

    private var backgroundColor: SwiftUI.Color {
        if image == nil {
            return Color.gray
        } else {
            return Color.clear
        }
    }
}

#if DEBUG
// swiftlint:disable:next type_name
struct NetworkImage_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        NetworkImage(imageURL: URL(string: "https://www.apple.com/favicon.ico")!)
    }
}
#endif
