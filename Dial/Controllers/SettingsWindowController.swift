// SettingsWindowController.swift
// Custom controller to show the Settings window with minimize support.

import SwiftUI
import AppKit

class SettingsWindowController {
    static var settingsWindowController: NSWindowController?
    
    static func open() {
        if settingsWindowController == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 620, height: 480),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.title = NSLocalizedString("Settings", comment: "Settings window title")
            window.contentView = NSHostingView(rootView: SettingsView())
            window.center()
            settingsWindowController = NSWindowController(window: window)
        }
        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.orderFrontRegardless()
    }
}
