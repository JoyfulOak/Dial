//  NSPanel+Mini.swift
//  Dial

import AppKit

extension NSPanel {
    static func miniFloating(contentViewController: NSViewController,
                             title: String,
                             width: CGFloat = 320) -> NSPanel {
        let p = NSPanel(contentViewController: contentViewController)
        p.styleMask = [.titled, .utilityWindow, .nonactivatingPanel]
        p.title = title
        p.setFrame(NSRect(x: 0, y: 0, width: width, height: 320), display: false)
        p.isMovableByWindowBackground = true
        p.isFloatingPanel = true
        p.becomesKeyOnlyIfNeeded = true
        p.level = .floating
        return p
    }
}
