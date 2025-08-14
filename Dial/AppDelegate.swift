//
//  AppDelegate.swift
//  Dial
//
//  Created by KrLite on 2024/3/22.
//

import Foundation
import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // Create the status item
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "hockeypuck", accessibilityDescription: "Dial")
        }
        let menu = NSMenu(title: "Dial Menu")
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
        item.menu = menu
        statusItem = item
        
        // Force load dial instance
        print("!!! Force loaded \(dial) !!!")
        
        PermissionsManager.requestAccess()
        SettingsWindowController.open()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApp.setActivationPolicy(.accessory)
        return false
    }
}
