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
        let navigationController = UINavigationController(nibName: nil, bundle: nil)
        let composeView = ComposeView(viewModel: viewModel)
        let composeViewController = UIHostingController(rootView: composeView)
//        composeViewController.didClose = { [weak self] in
//            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
//        }
        navigationController.viewControllers = [composeViewController]
        add(navigationController, view: view)
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

private class EmptyItemNavigator: ItemNavigatorProtocol {
    func showLogin() {

    }

    func open(url: URL) {

    }

    func open(author: Author) {

    }

    func open(authorName: String) {

    }

    func openFollowing(for user: Author) {

    }

    func openConversation(item: Item) {

    }

    func openMedia(media: [Media], index: Int) {

    }

    func openReply(item: Item) {

    }

    func share(item: Item, sourceView: UIView?) {

    }

    func accessibilityPresentLinks(linkList: [(text: String, url: URL)], message: String, sourceView: UIView) {

    }

    func openMore(item: Item, sourceView: UIView?) {

    }

    func showDiscoveryCategories(categories: [DiscoveryCategory], sourceView: UIView) {

    }
}
