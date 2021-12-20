//
//  Created by martin on 15.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import SwiftUI
import InsertLinkView
import Client

@objc(ShareViewController) class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            return
        }

        openCompose(for: items)
    }

    private func openCompose(for items: [NSExtensionItem]) {
        for item in items {
            guard let provider = item.attachments?.first else { return }

            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { [weak self] url, _ in
                    guard let self = self else { return }

                    guard let url = url else {
                        return
                    }

                    let viewModel = ComposeViewModel(mode: .shareURL(url: url, title: item.attributedContentText?.string ?? "Link"))
                    DispatchQueue.main.async {
                        self.openCompose(for: viewModel)
                    }
                }
            } else if provider.canLoadObject(ofClass: String.self) {
                _ = provider.loadObject(ofClass: String.self, completionHandler: { [weak self] string, _ in
                    guard let self = self else { return }

                    guard let text = string else {
                        return
                    }

                    let viewModel = ComposeViewModel(mode: .shareText(text: text))
                    DispatchQueue.main.async {
                        self.openCompose(for: viewModel)
                    }
                })
            }
        }
    }

    private func openCompose(for viewModel: ComposeViewModel) {
        var composeView = ComposeView(viewModel: viewModel)
        composeView.didClose = { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }

        let composeViewController = UIHostingController(rootView: composeView)
        add(composeViewController, view: view)
    }
}

@nonobjc extension UIViewController {
    func add(_ child: UIViewController, view: UIView) {
        addChild(child)

        child.view.frame = view.bounds
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
