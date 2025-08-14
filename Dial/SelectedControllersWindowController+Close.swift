// SelectedControllersWindowController+Close.swift
import AppKit

extension SelectedControllersWindowController {
    static func closeIfOpen() {
        let performClose = {
            NSApp.windows
                .compactMap { $0.windowController as? SelectedControllersWindowController }
                .forEach { $0.close() }
        }
        if Thread.isMainThread {
            performClose()
        } else {
            DispatchQueue.main.async {
                performClose()
            }
        }
    }
}
//
//  SelectedControllersWindowController+Close.swift
//  Dial
//
