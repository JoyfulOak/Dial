// ControllersMenuWindowController.swift
// Window controller for showing ControllersMenuView
import SwiftUI
import AppKit

class ControllersMenuWindowController: NSWindowController {
    static var current: ControllersMenuWindowController?

    static func open() {
        current?.close()
        let view = ControllersMenuView()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 380),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentView = NSHostingView(rootView: view)
        window.title = "Controllers"
        window.center()
        let controller = ControllersMenuWindowController(window: window)
        current = controller
        controller.showWindow(nil)
        window.orderFrontRegardless()
    }
}
