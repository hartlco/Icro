//
//  Created by martin on 18.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit

public protocol LoadingViewController: class {
    func showLoading(position: LoadingPosition)
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

    func showLoading(position: LoadingPosition = .bottom) {
        showMessage(text: localizedString(key: "UIVIEWCONTROLLERLOADING_LOADING_TEXT"),
                    color: Color.accent,
                    position: position,
                    dismissalTime: .forever)

    }

    func showError(error: Error, position: LoadingPosition = .bottom) {
        showMessage(text: error.text, color: Color.main, position: position, dismissalTime: .seconds(4))
    }

    func hideMessage() {
        hideWorkItem = makeHideMessageWorkItem()
        guard let hideWorkItem = hideWorkItem else { return }
        DispatchQueue.main.async(execute: hideWorkItem)
    }

    private func makeHideMessageWorkItem() -> DispatchWorkItem {
        return DispatchWorkItem {
            guard let loadingView = self.loadingView else { return }

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                loadingView.alpha = 0
                loadingView.anchor?.constant = loadingView.position == .top ? -loadingView.frame.size.height : loadingView.frame.size.height
                self.view.layoutIfNeeded()
            }, completion: { completed in
                guard completed else { return }
                loadingView.removeFromSuperview()
                self.loadingView = nil
            })
        }
    }

    public func showMessage(text: String,
                            color: UIColor,
                            position: LoadingPosition,
                            dismissalTime: LoadingIndicatorDismissalTime) {
        reset()

        let loadingView = LoadingView(text: text,
                                      color: color,
                                      position: position)
        loadingView.alpha = 0
        view.addSubview(loadingView)
        loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        let anchor: NSLayoutConstraint
        switch position {
        case .top:
            anchor = loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        case .bottom:
            anchor = loadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        }

        anchor.isActive = true
        loadingView.anchor = anchor
        self.loadingView = loadingView
        loadingView.layoutIfNeeded()
        anchor.constant = position == .top ? -(loadingView.frame.size.height) : loadingView.frame.size.height
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            loadingView.alpha = 1
            anchor.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)

        if case .seconds(let seconds) = dismissalTime {
            hideWorkItem = DispatchWorkItem {
                self.hideMessage()
            }
            guard let hideWorkItem = hideWorkItem else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: hideWorkItem)
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

private class LoadingView: UIView {
    private let label: UILabel
    var anchor: NSLayoutConstraint?
    var position: LoadingPosition

    init(text: String, color: UIColor, position: LoadingPosition) {
        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.position = position
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = Font().boldBody
        label.textColor = .white
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = color
        addSubview(label)
        let offset: CGFloat = 4
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offset).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -offset).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: offset).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

public extension Error {
    var text: String {
        if let networkingError = self as? NetworkingError {
            switch networkingError {
            case .wordPressURLError:
                return localizedString(key: "UIVIEWCONTROLLERLOADING_WORDPRESSURLERROR_TEXT")
            case .micropubURLError:
                return localizedString(key: "UIVIEWCONTROLLERLOADING_MICROPUBURLERROR_TEXT")
            case .invalidInput:
                return localizedString(key: "UIVIEWCONTROLLERLOADING_INVALIDINPUT_TEXT")
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
