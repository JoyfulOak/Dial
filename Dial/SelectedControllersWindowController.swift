// SelectedControllersWindowController.swift
// NSWindowController for SelectedControllersSettingsView
import SwiftUI
import AppKit

class SelectedControllersWindowController: NSWindowController {
    static var current: SelectedControllersWindowController?

    static func open(with controllers: [ControllerID]) {
        // Close previous if open
        current?.close()
        
        // TODO: Add corresponding closure parameter to SelectedControllersSettingsView initializer
        let view = SelectedControllersSettingsView(controllers: controllers) { _ in
            current?.close()
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 450),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.contentView = NSHostingView(rootView: view)
        window.title = "Controller Details"
        window.center()
        let controller = SelectedControllersWindowController(window: window)
        current = controller
        controller.showWindow(nil)
        window.orderFrontRegardless()
    }
}

