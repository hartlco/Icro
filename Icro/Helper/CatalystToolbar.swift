//
//  Created by martin on 20.07.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit

#if targetEnvironment(macCatalyst)
import AppKit
#endif

final class CatalystToolbar: NSObject {
    private let items: [ListViewModel.ListType] = ListViewModel.ListType.standardTabs(from: UserSettings.shared)

    #if targetEnvironment(macCatalyst)
    private let composeIdentifier = NSToolbarItem.Identifier("compose")

    var toolbar: NSToolbar {
        let toolbar = NSToolbar(identifier: NSToolbar.Identifier("MainToolbar"))
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
        return [NSToolbarItem.Identifier.flexibleSpace, composeIdentifier]
    }

    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.flexibleSpace, composeIdentifier]
    }

    @objc private func openNewWindow() {
//        let composeType = "co.hartl.icro.compose"
//
//        let userActivity = NSUserActivity(activityType: composeType)
//        userActivity.userInfo = ["ur": "Test"]
//
//        UIApplication.shared.requestSceneSessionActivation(nil,
//                                                           userActivity: userActivity,
//                                                           options: nil,
//                                                           errorHandler: { error in
//
//        })

        showCompose()

    }
}
#endif
