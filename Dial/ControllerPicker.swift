// ControllerPicker.swift
// NSWindowController for SelectedControllersSettingsView
import SwiftUI
import AppKit

class ControllerPicker: NSWindowController {
    static var current: ControllerPicker?

    // MARK: - Open window as floating NSPanel with minimal style
    static func open(with controllers: [ControllerID]) {
        // Close previous if open
        closeIfOpen()
        
        // Create SelectedControllersSettingsView with close closure
        let view = SelectedControllersSettingsView(controllers: controllers) { _ in
            current?.close()
        }
        
        // Calculate dynamic panel height based on controllers count
        let itemHeight: CGFloat = 56
        let headerFooterHeight: CGFloat = 110
        let minHeight: CGFloat = 320
        let maxHeight: CGFloat = 700
        let panelHeight = min(max(CGFloat(controllers.count) * itemHeight + headerFooterHeight, minHeight), maxHeight)
        
        // Create NSPanel instead of NSWindow for floating minimal style
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: panelHeight),
            styleMask: [.titled, .closable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        // Minimal window chrome and behavior settings
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        
        panel.contentView = NSHostingView(rootView: view)
        
        // Center near mouse point
        centerNearMouse(window: panel)
        
        let controller = ControllerPicker(window: panel)
        current = controller
        controller.showWindow(nil)
        panel.orderFrontRegardless()
    }

    // MARK: - Position window near mouse pointer
    private static func centerNearMouse(window: NSWindow) {
        guard let screen = NSScreen.screens.first else {
            window.center()
            return
        }
        var mouseLocation = NSEvent.mouseLocation
        // Convert mouse location to screen coordinates with origin bottom-left
        // macOS origin is bottom-left, mouseLocation already in that coordinate system
        
        // Adjust mouseLocation to keep window fully visible on screen
        let windowSize = window.frame.size
        let screenFrame = screen.visibleFrame
        
        // Offset window origin so that the window is centered horizontally on mouse x,
        // and vertically positioned just above the mouse pointer
        var originX = mouseLocation.x - windowSize.width / 2
        var originY = mouseLocation.y - windowSize.height - 20 // 20 px above mouse
        
        // Clamp to screen visible frame
        if originX < screenFrame.minX {
            originX = screenFrame.minX + 10
        } else if originX + windowSize.width > screenFrame.maxX {
            originX = screenFrame.maxX - windowSize.width - 10
        }
        if originY < screenFrame.minY {
            originY = screenFrame.minY + 10
        } else if originY + windowSize.height > screenFrame.maxY {
            originY = screenFrame.maxY - windowSize.height - 10
        }

        window.setFrameOrigin(NSPoint(x: originX, y: originY))
    }
}
