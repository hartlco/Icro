//
//  Created by martin on 04.11.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import SnapKit

final class LoadMoreTableViewCell: UITableViewCell {
    private let button = UIButton()
    private let stackView = UIStackView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var isLoading = false

    var didPressLoadMore: (() -> Void)?

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
        applyAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        isLoading = false
        applyAppearance()
    }

    private func setup() {
        button.setTitleColor(Color.main, for: .normal)
        button.setTitleColor(Color.accentLight, for: .disabled)
        button.addTarget(self,
                         action: #selector(loadMorePressed(_:)),
                         for: .touchUpInside)

        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = 10

        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        stackView.addArrangedSubview(button)
    }

    private func applyAppearance() {
        backgroundColor = Color.backgroundColor

        if isLoading {
            button.setTitle(NSLocalizedString("UIVIEWCONTROLLERLOADING_LOADING_TEXT",
                                              comment: "Loading"),
                            for: .normal)
            button.isEnabled = false
            stackView.insertArrangedSubview(activityIndicator, at: 0)
            activityIndicator.startAnimating()
        } else {
            button.setTitle(NSLocalizedString("UIVIEWCONTROLLERLOADING_LOADING_MORE",
                                              comment: "Load More"),
                            for: .normal)
            button.isEnabled = true
            stackView.removeArrangedSubview(activityIndicator)
            activityIndicator.stopAnimating()
        }
    }

    @objc private func loadMorePressed(_ sender: Any) {
        didPressLoadMore?()
        isLoading = true

        applyAppearance()
    }
}
