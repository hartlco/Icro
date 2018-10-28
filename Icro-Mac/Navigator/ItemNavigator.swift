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
        newWindow.titlebarAppearsTransparent = true
        newWindow.isMovableByWindowBackground  = true
        newWindow.styleMask.insert(.fullSizeContentView)
        newWindow.title = "New Post"
        let customToolbar = NSToolbar()
        newWindow.titleVisibility = .hidden
        newWindow.toolbar = customToolbar
        newWindow.toolbar?.showsBaselineSeparator = false
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

    func open(authorName: String) {
        let viewModel = ListViewModel(type: .username(username: authorName))
        let viewController = ListViewController(listViewModel: viewModel, itemNavigator: self)
        let newWindow = NSWindow(contentViewController: viewController)
        let newWindowController = NSWindowController(window: newWindow)
        viewController.title = authorName
        newWindowController.showWindow(nil)
    }

    func openSettings() {
        let storyboard = NSStoryboard(name: "SettingsStoryboard", bundle: nil)
        guard let windowController = storyboard.instantiateInitialController() as? NSWindowController else { return }
        windowController.showWindow(nil)
    }

    func openURL(_ url: URL) {
        if let username = username(from: url) {
            open(authorName: username)
            return
        }

        NSWorkspace.shared.open(url)
    }
}
