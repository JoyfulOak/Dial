// ControllersWindowOpener.swift
// Utility to programmatically open the Controllers menu window scene
import AppKit
import SwiftUI

enum ControllersWindowOpener {
    static func openControllersWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("openWindowWithID:")), to: nil, from: "controllers-menu")
        } else {
            showLegacyControllersWindow()
        }
    }

    @available(macOS, deprecated: 13.0)
    private static func showLegacyControllersWindow() {
        let vc = NSHostingController(rootView: ControllersMenuView())
        let win = NSWindow(contentViewController: vc)
        win.title = "Controllers"
        win.styleMask = [.titled, .closable, .miniaturizable]
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
