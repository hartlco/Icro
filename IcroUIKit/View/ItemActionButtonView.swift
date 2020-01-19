//
//  Created by Martin Hartl on 25.12.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import SnapKit
import TypedSymbols
import IcroKit

final public class ItemActionButtonView: UIView {
    public enum Action {
        case reply
        case conversation
        case share
        case favorite
        case dismiss
    }

    private let replyButton = UIButton()
    private let conversationButton = UIButton()
    private let favoriteButton = UIButton()
    private let shareButton = UIButton()
    private let stackView = UIStackView()

    public init() {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var didPress: (Action) -> Void = { _ in }

    public var isFavorite = false {
        didSet {
            if isFavorite {
                favoriteButton.setImage(UIImage(symbol: .star_fill), for: .normal)
            } else {
                favoriteButton.setImage(UIImage(symbol: .star), for: .normal)
            }
        }
    }

    // MARK: - Private

    @objc private func didPress(button: NSObject) {
        switch button {
        case _ where button == replyButton:
            didPress(.reply)
        case _ where button == conversationButton:
            didPress(.conversation)
        case _ where button == shareButton:
            didPress(.share)
        case _ where button == favoriteButton:
            didPress(.favorite)
        default:
            didPress(.dismiss)
        }
    }

    func setupLayout() {
        backgroundColor = .clear
        stackView.addBackground(color: Color.buttonColor ?? UIColor.systemBackground)

        replyButton.setImage(UIImage(symbol: .arrowshape_turn_up_left), for: .normal)
        conversationButton.setImage(UIImage(symbol: .bubble_left_and_bubble_right), for: .normal)
        favoriteButton.setImage(UIImage(symbol: .star), for: .normal)
        shareButton.setImage(UIImage(symbol: .square_and_arrow_up), for: .normal)

        replyButton.addTarget(self, action: #selector(didPress(button:)), for: .touchUpInside)
        conversationButton.addTarget(self, action: #selector(didPress(button:)), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(didPress(button:)), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didPress(button:)), for: .touchUpInside)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPress(button:)))
        addGestureRecognizer(tapRecognizer)

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(44)
        }

        stackView.addArrangedSubview(replyButton)
        stackView.addArrangedSubview(conversationButton)
        stackView.addArrangedSubview(favoriteButton)
        stackView.addArrangedSubview(shareButton)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
    }
}

private extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
