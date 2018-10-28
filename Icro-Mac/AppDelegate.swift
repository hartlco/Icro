//
//  AppDelegate.swift
//  Icro-Mac
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let window = NSApplication.shared.mainWindow
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground  = true
        window?.styleMask.insert(.fullSizeContentView)
        let customToolbar = NSToolbar()
        window?.titleVisibility = .hidden
        window?.toolbar = customToolbar
        window?.toolbar?.showsBaselineSeparator = false
    }

    func applicationWillTerminate(_ aNotification: Notification) { }
}
