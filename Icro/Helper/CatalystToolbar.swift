//
//  Created by martin on 20.07.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import Settings

#if targetEnvironment(macCatalyst)
import AppKit
#endif

protocol CatalystToolbarDelegate: AnyObject {
    func didRequestToOpenCompose()
}

final class CatalystToolbar: NSObject {
    weak var delegate: CatalystToolbarDelegate?

    private let items: [ListViewModel.ListType] = ListViewModel.ListType.standardTabs(from: UserSettings.shared)

    #if targetEnvironment(macCatalyst)
    private let composeIdentifier = NSToolbarItem.Identifier("compose")
    private let mainToolbarIdentifier = NSToolbar.Identifier("MainToolbar")
    private let composeToolbarIdentifier = NSToolbar.Identifier("ComposeToolbar")

    var toolbar: NSToolbar {
        let toolbar = NSToolbar(identifier: mainToolbarIdentifier)
        toolbar.delegate = self
        return toolbar
    }

    var composeToolbar: NSToolbar {
        let toolbar = NSToolbar(identifier: composeToolbarIdentifier)
        toolbar.delegate = self
        return toolbar
    }
    #endif

    var showCompose: () -> Void = { }
}

#if targetEnvironment(macCatalyst)
extension CatalystToolbar: NSToolbarDelegate {
    public func toolbar(_ toolbar: NSToolbar,
                        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                        willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        var toolbarItem: NSToolbarItem

        switch itemIdentifier {
        case NSToolbarItem.Identifier.flexibleSpace:
            toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        case composeIdentifier:
            let barButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(openNewWindow))
            let item = NSToolbarItem(itemIdentifier: composeIdentifier, barButtonItem: barButton)
            toolbarItem = item
        default:
            fatalError()
        }

        return toolbarItem
    }

    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        switch toolbar.identifier {
        case mainToolbarIdentifier:
            return [NSToolbarItem.Identifier.flexibleSpace, composeIdentifier]
        case composeToolbarIdentifier:
            return [NSToolbarItem.Identifier.flexibleSpace]
        default:
            return []
        }
    }

    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        switch toolbar.identifier {
        case mainToolbarIdentifier:
            return [NSToolbarItem.Identifier.flexibleSpace, composeIdentifier]
        case composeToolbarIdentifier:
            return [NSToolbarItem.Identifier.flexibleSpace]
        default:
            return []
        }
    }

    @objc private func openNewWindow() {
        delegate?.didRequestToOpenCompose()
    }
}
#endif
