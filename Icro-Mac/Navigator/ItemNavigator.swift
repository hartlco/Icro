//
//  ItemNavigator.swift
//  Icro-Mac
//

import Foundation
import Cocoa
import IcroKit_Mac

final class ItemNavigator {
    func openConversation(for item: Item) {
        let viewModel = ListViewModel(type: .conversation(item: item))
        let viewController = ListViewController(listViewModel: viewModel, itemNavigator: self)
        let newWindow = NSWindow(contentViewController: viewController)
        let newWindowController = NSWindowController(window: newWindow)
        newWindowController.showWindow(nil)
    }

    func openURL(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}
