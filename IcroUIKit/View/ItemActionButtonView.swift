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

    @objc private func didPress(button: UIButton) {
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
            return
        }
    }

    func setupLayout() {
        backgroundColor = Color.buttonColor

        replyButton.setImage(UIImage(symbol: .arrowshape_turn_up_left), for: .normal)
        conversationButton.setImage(UIImage(symbol: .bubble_left_and_bubble_right), for: .normal)
        favoriteButton.setImage(UIImage(symbol: .star), for: .normal)
        shareButton.setImage(UIImage(symbol: .square_and_arrow_up), for: .normal)

        replyButton.addTarget(self, action: #selector(didPress(button:)), for: .touchUpInside)
        conversationButton.addTarget(self, action: #selector(didPress(button:)), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(didPress(button:)), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didPress(button:)), for: .touchUpInside)

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.addArrangedSubview(replyButton)
        stackView.addArrangedSubview(conversationButton)
        stackView.addArrangedSubview(favoriteButton)
        stackView.addArrangedSubview(shareButton)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
}
