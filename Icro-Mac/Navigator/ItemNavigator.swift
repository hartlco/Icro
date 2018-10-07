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

    func openCompose() {
        let viewModel = ComposeViewModel(mode: .post)
        let viewController = ComposeViewController(composeViewModel: viewModel)
        let newWindow = NSWindow(contentViewController: viewController)
        let newWindowController = NSWindowController(window: newWindow)
        newWindowController.showWindow(nil)
    }

    func openReply(for item: Item) {
        let viewModel = ComposeViewModel(mode: .reply(item: item))
        let viewController = ComposeViewController(composeViewModel: viewModel)
        let newWindow = NSWindow(contentViewController: viewController)
        let newWindowController = NSWindowController(window: newWindow)
        newWindowController.showWindow(nil)
    }

    func openSettings() {
        let storyboard = NSStoryboard(name: "SettingsStoryboard", bundle: nil)
        guard let windowController = storyboard.instantiateInitialController() as? NSWindowController else { return }
        windowController.showWindow(nil)
    }

    func openURL(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}
