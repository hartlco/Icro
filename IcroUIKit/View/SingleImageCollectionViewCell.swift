import UIKit
import Kingfisher

final class SingleImageCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    let videoPlayImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "play.fill"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .white
        view.contentMode = .center
        view.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        view.layer.cornerRadius = 22
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 12
        contentView.addSubview(imageView)
        contentView.addSubview(videoPlayImage)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            videoPlayImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            videoPlayImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            videoPlayImage.widthAnchor.constraint(equalToConstant: 44),
            videoPlayImage.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        videoPlayImage.isHidden = true
    }
}
