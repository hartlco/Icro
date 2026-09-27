import UIKit

final class LoadMoreTableViewCell: UITableViewCell {
    private let retryButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    var didPressLoadMore: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle(NSLocalizedString("TIMELINE_RETRY_LOADING", comment: "Retry loading older posts"), for: .normal)
        retryButton.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        retryButton.addTarget(self, action: #selector(retryPressed), for: .touchUpInside)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .secondaryLabel

        contentView.addSubview(retryButton)
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            retryButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            retryButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        showLoading()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        didPressLoadMore = nil
        showLoading()
    }

    func showLoading() {
        retryButton.isHidden = true
        activityIndicator.startAnimating()
    }

    func showRetry() {
        activityIndicator.stopAnimating()
        retryButton.isHidden = false
    }

    @objc private func retryPressed() {
        showLoading()
        didPressLoadMore?()
    }
}
