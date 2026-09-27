//
//  Created by martin on 18.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import Client
import Style

extension UIViewController: LoadingViewController { }

public protocol LoadingViewController: AnyObject {
    func showLoading(position: LoadingPosition, dismissalTime: LoadingIndicatorDismissalTime)
    func showError(error: Error, position: LoadingPosition)
    func hideMessage()
}

struct AssociatedKeys {
    static var loadingViewKey = 0
    static var hideWorkItem = 1
}

public extension LoadingViewController where Self: UIViewController {
    private var loadingView: LoadingView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.loadingViewKey) as? LoadingView
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.loadingViewKey,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var hideWorkItem: DispatchWorkItem? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.hideWorkItem) as? DispatchWorkItem
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.hideWorkItem,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func showLoading(position: LoadingPosition = .bottom, dismissalTime: LoadingIndicatorDismissalTime = .forever) {
        showMessage(text: localizedString(key: "UIVIEWCONTROLLERLOADING_LOADING_TEXT"),
                    color: Color.accent,
                    position: position,
                    dismissalTime: dismissalTime)

    }

    func showError(error: Error, position: LoadingPosition = .bottom) {
        showMessage(text: error.text, color: Color.main, position: position, dismissalTime: .seconds(4))
    }

    func hideMessage() {
        hideWorkItem?.cancel()
        hideWorkItem = nil
        guard let loadingView else { return }

        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseIn, animations: {
            loadingView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { completed in
            guard completed, self.loadingView === loadingView else { return }
            loadingView.removeFromSuperview()
            self.loadingView = nil
        })
    }

    func showMessage(text: String,
                     color: UIColor,
                     position: LoadingPosition,
                     dismissalTime: LoadingIndicatorDismissalTime) {
        reset()

        let showsSpinner: Bool
        switch dismissalTime {
        case .forever: showsSpinner = true
        case .seconds: showsSpinner = false
        }
        let loadingView = LoadingView(text: text, color: color, showsSpinner: showsSpinner)
        guard let ownView = view else { return }
        let host: UIView = position == .bottom ? (tabBarController?.view ?? ownView) : ownView
        host.layoutIfNeeded()
        host.addSubview(loadingView)

        let preferredWidth = loadingView.widthAnchor.constraint(equalToConstant: 360)
        preferredWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: host.safeAreaLayoutGuide.centerXAnchor),
            loadingView.leadingAnchor.constraint(greaterThanOrEqualTo: host.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loadingView.trailingAnchor.constraint(lessThanOrEqualTo: host.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            preferredWidth
        ])

        switch position {
        case .top:
            loadingView.topAnchor.constraint(equalTo: host.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        case .bottom:
            if let tabBar = tabBarController?.tabBar,
               tabBar.isDescendant(of: host),
               !tabBar.isHidden,
               tabBar.convert(tabBar.bounds, to: host).minY > host.bounds.midY {
                loadingView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -12).isActive = true
            } else {
                loadingView.bottomAnchor.constraint(equalTo: host.safeAreaLayoutGuide.bottomAnchor, constant: -12).isActive = true
            }
        }

        self.loadingView = loadingView
        loadingView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)

        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            loadingView.transform = .identity
        }, completion: nil)

        if case .seconds(let seconds) = dismissalTime {
            let workItem = DispatchWorkItem { [weak self] in
                self?.hideMessage()
            }
            hideWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: workItem)
        }
    }

    private func reset() {
        hideWorkItem?.cancel()
        hideWorkItem = nil
        self.loadingView?.removeFromSuperview()
    }
}

public enum LoadingPosition {
    case top
    case bottom
}

public enum LoadingIndicatorDismissalTime {
    case forever
    case seconds(_ : TimeInterval)
}

private final class LoadingView: UIVisualEffectView {
    init(text: String, color: UIColor, showsSpinner: Bool) {
        let glass = UIGlassEffect(style: .regular)
        glass.tintColor = color.withAlphaComponent(0.12)
        super.init(effect: glass)

        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 22
        clipsToBounds = true
        isUserInteractionEnabled = false
        accessibilityLabel = text

        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.text = text

        let indicator: UIView
        if showsSpinner {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = color
            spinner.startAnimating()
            indicator = spinner
        } else {
            let image = UIImageView(image: UIImage(systemName: "exclamationmark.circle.fill"))
            image.tintColor = color
            image.contentMode = .scaleAspectFit
            indicator = image
        }
        indicator.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [indicator, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

public extension Error {
    var text: String {
        if let networkingError = self as? NetworkingError {
            switch networkingError {
            case .invalidInput:
                return localizedString(key: "UIVIEWCONTROLLERLOADING_INVALIDINPUT_TEXT")
            case .httpStatus(401):
                return localizedString(key: "UIVIEWCONTROLLERLOADING_SESSION_EXPIRED_TEXT")
            default:
                return localizedString(key: "UIVIEWCONTROLLERLOADING_ERROR_TEXT")
            }
        }

        if let purchaseError = self as? PurchaseError {
            switch purchaseError {
            case .paymentError:
                return localizedString(key: "IN-APP-PURCHASE-STATE-PURCHASE-ERROR")
            }
        }

        return localizedString(key: "UIVIEWCONTROLLERLOADING_ERROR_TEXT")
    }
}
