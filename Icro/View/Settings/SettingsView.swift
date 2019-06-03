//
//  Created by Martin Hartl on 02.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

enum SettingsCellType {
    case labelWithButton(configBlock: (SettingsButtonWithLabelView) -> Void)
    case labelWithSwitch(configBlock: (SettingsSwitchWithLabelView) -> Void)
    case button(configBlock: (SettingsButton) -> Void)
    case inputView(configBlock: (SettingsTextInputView) -> Void)
    case internalSettingsView(view: SettingsView, config: (SettingsView) -> Void)
    case custom(view: UIView)
}

struct SettingsSection {
    let title: String?
    let subTitle: String?
    let cellTypes: [SettingsCellType]
}

final class SettingsView: UIView {
    enum Appearance {
        case groupedFullWidth
        case groupedRounded(inset: CGFloat)
    }

    struct Config {
        let minimumCellHeight: CGFloat
        let headerHeight: CGFloat
        let footerHeight: CGFloat
        let sectionSpacing: CGFloat
        let appearance: Appearance
        let hideTopBottomSeparators: Bool

        init(minimumCellHeight: CGFloat = 50,
             headerHeight: CGFloat = 40,
             footerHeight: CGFloat = 40,
             sectionSpacing: CGFloat = 10,
             appearance: SettingsView.Appearance = .groupedRounded(inset: 24),
             hideTopBottomSeparators: Bool = false) {
            self.minimumCellHeight = minimumCellHeight
            self.headerHeight = headerHeight
            self.footerHeight = footerHeight
            self.sectionSpacing = sectionSpacing
            self.appearance = appearance
            self.hideTopBottomSeparators = hideTopBottomSeparators
        }

        static let `default` = Config()
    }

    private let stackView = UIStackView(frame: .zero)

    private var configs: [() -> Void] = []

    var config = Config.default {
        didSet {
            updateAppearance()
            updateSections()
        }
    }

    init(config: Config = .default) {
        super.init(frame: .zero)
        self.config = config
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not supported")
    }

    var sections: [SettingsSection] = [] {
        didSet {
            updateSections()
        }
    }

    func update() {
        for config in configs {
            config()
        }
    }

    private var fittingSize: CGSize {
        return stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }

    private func updateAppearance() {
        let inset: CGFloat

        switch config.appearance {
        case .groupedFullWidth:
            inset = 0
        case .groupedRounded(let groupedInset):
            inset = groupedInset
        }

        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset).isActive = true
    }

    private func setup() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        updateAppearance()
        backgroundColor = Color.accentSuperLight
        stackView.alignment = UIStackView.Alignment.fill
        stackView.distribution = UIStackView.Distribution.fill
        stackView.axis = .vertical
    }

    private func updateSections() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for (index, section) in sections.enumerated() {
            if let title = section.title {
                let header = SettingsSectionHeaderView(frame: .zero)
                header.translatesAutoresizingMaskIntoConstraints = false
                header.title = title
                header.heightAnchor.constraint(equalToConstant: config.headerHeight).isActive = true
                stackView.addArrangedSubview(header)
            }

            if case .groupedFullWidth = config.appearance, !config.hideTopBottomSeparators {
                stackView.addArrangedSubview(SettingsSeparatorView(frame: .zero))
            }

            for (index, type) in section.cellTypes.enumerated() {
                let viewForType = view(for: type)
                stackView.addArrangedSubview(viewForType)

                if index != section.cellTypes.endIndex - 1 {
                    stackView.addArrangedSubview(SettingsInlineSeparatorView(frame: .zero))
                }

                if section.cellTypes.count == 1 {
                    viewForType.round(corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner])
                } else if index == section.cellTypes.startIndex, case .groupedRounded = config.appearance {
                    viewForType.round(corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner])
                } else if index == section.cellTypes.endIndex - 1, case .groupedRounded = config.appearance {
                    viewForType.round(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
                }
            }

            if case .groupedFullWidth = config.appearance, !config.hideTopBottomSeparators {
                stackView.addArrangedSubview(SettingsSeparatorView(frame: .zero))
            }

            if let subtitle = section.subTitle {
                let subtitleView = SettingsSectionSubtitleView(frame: .zero)
                subtitleView.translatesAutoresizingMaskIntoConstraints = false
                subtitleView.title = subtitle
                subtitleView.heightAnchor.constraint(greaterThanOrEqualToConstant: config.footerHeight).isActive = true
                stackView.addArrangedSubview(subtitleView)
            }

            if index != sections.endIndex - 1 {
                let spacingView = UIView(frame: .zero)
                spacingView.heightAnchor.constraint(equalToConstant: config.sectionSpacing).isActive = true
                stackView.addArrangedSubview(spacingView)
            }
        }
    }

    private func view(for cellType: SettingsCellType) -> UIView {
        switch cellType {
        case .button(let configBlock):
            let button = SettingsButton(frame: .zero)
            configBlock(button)
            button.heightAnchor.constraint(equalToConstant: config.minimumCellHeight).isActive = true
            return button
        case .inputView(let configBlock):
            let input = SettingsTextInputView(frame: .zero)
            configBlock(input)
            configs.append({
                configBlock(input)
            })
            input.heightAnchor.constraint(equalToConstant: config.minimumCellHeight).isActive = true
            return input
        case .labelWithButton(let configBlock):
            let view = SettingsButtonWithLabelView(frame: .zero)
            configBlock(view)
            view.heightAnchor.constraint(equalToConstant: config.minimumCellHeight).isActive = true
            return view
        case .labelWithSwitch(let configBlock):
            let view = SettingsSwitchWithLabelView(frame: .zero)
            configBlock(view)
            view.heightAnchor.constraint(equalToConstant: config.minimumCellHeight).isActive = true
            return view
        case .custom(let view):
            return view
        case .internalSettingsView(let view, let configBlock):
            configBlock(view)
            configs.append({
                configBlock(view)
            })
            view.heightAnchor.constraint(equalToConstant: view.fittingSize.height).isActive = true
            return view
        }
    }
}

private extension UIView {
    func round(corners: CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.maskedCorners = corners
    }
}
