// ControllerPicker+Close.swift
import AppKit

extension ControllerPicker {
    static func closeIfOpen() {
        let performClose = {
            NSApp.windows
                .compactMap { $0.windowController as? ControllerPicker }
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
//  ControllerPicker+Close.swift
//  Dial
//
