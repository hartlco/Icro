//
//  Created by martin on 07.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import Style

final class SingleImageCollectionViewCell: UICollectionViewCell {
    let videoPlayImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "play-button")

        return imageView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        videoPlayImage.isHidden = true
    }

    override func prepareForReuse() {
        updateAppearance()
        imageView.image = nil
    }

    private func updateAppearance() {
        addSubview(imageView)
        addSubview(videoPlayImage)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            videoPlayImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            videoPlayImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            videoPlayImage.heightAnchor.constraint(equalToConstant: 34.0),
            videoPlayImage.widthAnchor.constraint(equalToConstant: 34.0)
        ])

        imageView.backgroundColor = Color.accentLight
    }
}
